require_relative "../rails_helper"

RSpec.describe StandardProcedure::HasFieldValues do
  let(:category) { Category.create name: "Category" }
  let(:thing) { Thing.create name: "Thing No. 1" }

  it "adds accessors for each defined field" do
    category.field_definitions.create reference: "address", name: "Address", type: "StandardProcedure::FieldDefinition::Address"
    category.field_definitions.create reference: "number", name: "Number", type: "StandardProcedure::FieldDefinition::Number"
    category.field_definitions.create reference: "another_category", name: "Another Category", type: "StandardProcedure::FieldDefinition::Model", model_class: "Category"

    thing.with_fields_from(category.field_definitions) do |t|
      expect(t).to respond_to(:address)
      expect(t).to respond_to(:"address=")
      expect(t).to respond_to(:number)
      expect(t).to respond_to(:"number=")
      expect(t).to respond_to(:another_category)
      expect(t).to respond_to(:"another_category=")
    end
  end

  it "typecasts the field data"
  it "validates the field data"
  it "enforces mandatory fields"
  it "sets a default value for fields"
  it "generates a calculated value for fields"
end
