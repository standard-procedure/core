require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowAction do
    class SomeAction < StandardProcedure::WorkflowAction
      required_fields << :first_field 
      required_fields << :second_field
    end

    it "records its required fields" do
      expect(SomeAction.required_fields).to eq [:first_field, :second_field]
    end
  end
end
