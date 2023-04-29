module StandardProcedure
  class Command < ApplicationRecord
    belongs_to :context, class_name: "StandardProcedure::Command", optional: true
    belongs_to :user, polymorphic: true, optional: true
    belongs_to :target, polymorphic: true, optional: true
    has_many :follow_on_commands, class_name: "StandardProcedure::Command", foreign_key: "context_id", dependent: :nullify
    enum status: {ready: 0, in_progress: 10, completed: 100, failed: -1}
    has_fields
    has_field :job_id
    has_hash :params
    has_field :error
    has_linked :items, class_name: "StandardProcedure::CommandLink"
    validates :command, presence: true
    after_save :link_related_items

    def to_s
      command
    end

    def result
      params[:result]
    end

    def error
      params[:error]
    end

    class << self
      def context_stack
        Thread.current[:context_stack] ||= []
      end

      def context
        context_stack.last
      end
    end

    protected

    def link_related_items
      link_to user
      link_to target
      params.each do |key, value|
        link_to value if value.is_a? ActiveRecord::Base
      end
    end
  end
end
