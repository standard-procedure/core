require_relative "../rails_helper"

RSpec.describe StandardProcedure::HasFieldDefinitions do
  it "adds the field_definitions association" do
    expect(Category.new).to respond_to(:field_definitions)
  end

  describe "associations defined on another model " do
    Category.class_eval do
      has_many_extended :things, dependent: :destroy
    end

    let(:category) { a_saved Category }

    before do
      category.field_definitions.create reference: "number", name: "Number", type: "StandardProcedure::FieldDefinition::Number"
    end

    it "creates new models with the fields pre-defined" do
      thing = category.things.create_with_fields_from! category, name: "Thing", number: 123
      expect(thing.name).to eq "Thing"
      expect(thing.number).to eq 123
    end

    it "finds existing models or creates new ones with the fields pre-defined" do
      first = category.things.create_with_fields_from! category, name: "First", number: 123

      thing = category.things.where(name: "First").first_or_create_with_fields_from!(category, number: 456)
      expect(thing).to eq first
      expect(thing.number).to eq 123

      other_thing = category.things.where(name: "Second").first_or_create_with_fields_from!(category, number: 456)
      expect(other_thing.name).to eq "Second"
      expect(other_thing.number).to eq 456
    end
  end
end
