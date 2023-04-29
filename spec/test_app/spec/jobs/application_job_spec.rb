require "rails_helper"
module StandardProcedure
  class TestParametersJob < ApplicationJob
    def perform thing, user:, item:
      item
    end
  end

  class TestSingleJob < ApplicationJob
    def perform arg: nil
      "DONE"
    end
  end

  class TestMultipleJob < ApplicationJob
    def perform action = :perform_now
      TestMultipleChildJob.send action
      "PARENT"
    end
  end

  class TestMultipleChildJob < ApplicationJob
    def perform
      TestMultipleGrandChildJob.perform_now
      "CHILD"
    end
  end

  class TestMultipleGrandChildJob < ApplicationJob
    def perform
      "GRANDCHILD"
    end
  end

  class TestFailedJob < ApplicationJob
    def perform
      raise "BOOM"
    end
  end

  class TestModelJob < ApplicationJob
    def perform category:, thing:
      "Got some parameters"
    end
  end

  class TestWaitJob < ApplicationJob
    cattr_reader :lock

    def perform
      # Pause till given the go-ahead
      self.class.lock.take
      # Tell the lock we are done
      self.class.lock.put :done
    end

    class << self
      def lock
        @lock ||= Concurrent::MVar.new
      end
    end
  end

  RSpec.describe ApplicationJob, type: :job do
    it "logs the command for a single job" do
      TestSingleJob.perform_now arg: "Hello"

      command = StandardProcedure::Command.first
      expect(command.command).to eq TestSingleJob.name
      expect(command.job_id).to_not be_blank
      expect(command.params[:arg]).to eq "Hello"
      expect(command.result).to eq "DONE"
      expect(command.status).to eq "completed"
    end

    it "logs the target and user command for a single job" do
      thing = a_saved Thing
      user = a_saved User
      TestParametersJob.perform_now thing, user: user, item: "Item"

      command = StandardProcedure::Command.first
      expect(command.target).to eq thing
      expect(command.user).to eq user
    end

    it "logs the command for descendant jobs in the context of the parent job" do
      TestMultipleJob.perform_now

      parent = StandardProcedure::Command.first
      child = StandardProcedure::Command.second
      grandchild = StandardProcedure::Command.last
      expect(parent.command).to eq TestMultipleJob.name
      expect(child.command).to eq TestMultipleChildJob.name
      expect(child.context).to eq parent
      expect(grandchild.command).to eq TestMultipleGrandChildJob.name
      expect(grandchild.context).to eq child
    end

    it "passes the context through to jobs that are performed later" do
      TestMultipleJob.queue_adapter = :inline
      TestMultipleChildJob.queue_adapter = :inline

      TestMultipleJob.perform_now :perform_later

      parent = StandardProcedure::Command.first
      child = StandardProcedure::Command.second
      grandchild = StandardProcedure::Command.last
      expect(child.context).to eq parent
      expect(grandchild.context).to eq child
    ensure
      TestMultipleJob.queue_adapter = :test
      TestMultipleChildJob.queue_adapter = :test
    end

    it "logs the failure of the job" do
      expect { TestFailedJob.perform_now }.to raise_exception(RuntimeError)

      command = StandardProcedure::Command.first
      expect(command.status).to eq "failed"
      expect(command.error).to include "BOOM"
    end

    it "logs links to the parameters of the command" do
      category = a_saved Category
      thing = a_saved Thing
      TestModelJob.perform_now category: category, thing: thing
      command = StandardProcedure::Command.first
      expect(command.items).to include category
      expect(command.items).to include thing
    end
  end
end
