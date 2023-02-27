require_relative "../rails_helper"

RSpec.describe StandardProcedure::HasFields do
  let(:category) { Category.create name: "Category No. 1" }
  let(:category_2) { Category.create name: "Category No. 2" }
  let(:thing) { Thing.create name: "Thing No. 1", category: category }
  let(:thing_2) { Thing.create name: "Thing No. 2", category: category }

  it "adds accessors" do
    Thing.class_eval do
      has_field :my_field
      has_model :my_model
      has_hash :my_hash
      has_array :my_array
    end

    [:my_field, :my_model, :my_hash, :my_array].each do |field_name|
      expect(thing).to respond_to(field_name)
      expect(thing).to respond_to(:"#{field_name}=")
    end
  end

  it "stores standard fields" do
    Thing.class_eval do
      has_field :my_field
    end
    thing.update my_field: "my_value"
    thing.reload
    expect(thing.my_field).to eq "my_value"
  end

  it "has default values for standard fields" do
    Thing.class_eval do
      has_field :my_field, default: "initial"
    end
    expect(thing.my_field).to eq "initial"
  end

  it "stores references to models" do
    Thing.class_eval do
      has_model :my_thing, "Thing"
    end
    thing.update my_thing: thing_2
    thing.reload
    expect(thing.my_thing).to eq thing_2
  end

  it "stores arrays"
  it "stores hashes"
  it "indexes string values"
  it "indexes number values"
  it "indexes date values"
  it "indexes date-time values"
  it "indexes models"

  it "adds standard fields to instances" do
    thing.has_field :my_internal_field, default: "initial"
    expect(thing).to respond_to(:my_internal_field)
    expect(thing_2).to_not respond_to(:my_internal_field)

    expect(thing.my_internal_field).to eq "initial"
    thing.update my_internal_field: "my_value"
    thing.reload
    expect(thing.my_internal_field).to eq "my_value"
  end
  it "adds model fields to instances" do
    thing.has_model :my_internal_category, "Category"
    expect(thing).to respond_to(:my_internal_category)
    expect(thing_2).to_not respond_to(:my_internal_category)

    thing.update my_internal_category: category_2
    thing.reload
    expect(thing.my_internal_category).to eq category_2
  end
  it "adds array fields to instances" do
    thing.has_array :my_internal_array
    expect(thing).to respond_to(:my_internal_array)
    expect(thing_2).to_not respond_to(:my_internal_array)

    thing.update my_internal_array: [1, 2, 3]
    thing.reload
    expect(thing.my_internal_array).to eq [1, 2, 3]
  end
  it "adds hash fields to instances" do
    thing.has_hash :my_internal_hash
    expect(thing).to respond_to(:my_internal_hash)
    expect(thing_2).to_not respond_to(:my_internal_hash)

    thing.update my_internal_hash: { key: "value" }
    thing.reload
    expect(thing.my_internal_hash).to eq({ key: "value" })
  end

  describe "from field definitions" do
    it "adds accessors for each defined field" do
      category.field_definitions.create reference: "address", name: "Address", type: "StandardProcedure::FieldDefinition::Address"
      category.field_definitions.create reference: "number", name: "Number", type: "StandardProcedure::FieldDefinition::Number"
      category.field_definitions.create reference: "another_category", name: "Another Category", type: "StandardProcedure::FieldDefinition::Model", model_type: "Category"

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
end
