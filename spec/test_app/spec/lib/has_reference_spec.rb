require_relative "../rails_helper"

RSpec.describe StandardProcedure::HasReference do
  it "generates a random reference"
  it "generates a reference with a prefix"
  it "generates a reference with a given length"
  it "uses the provided reference"
  it "copies the reference to another field"
  it "does not copy the reference if the other field has a value"
  it "uses the reference as the URL parameter"
  it "finds referenced child records"
  it "updates the referenced parent record"

  #   describe "finding" do
  #     it "finds by string reference" do
  #       Thing.class_eval do
  #         has_reference
  #       end
  #
  #       thing = a_saved Thing, name: "Thing"
  #       found = Thing.find_by_reference thing.reference
  #       expect(found).to eq thing
  #     end
  #     it "finds by ID" do
  #       Thing.class_eval do
  #         has_reference
  #       end
  #
  #       thing = a_saved Thing, name: "Thing"
  #       found = Thing.find_by_reference thing.id.to_s
  #       expect(found).to eq thing
  #     end
  #     it "finds by object" do
  #       Thing.class_eval do
  #         has_reference
  #       end
  #
  #       thing = a_saved Thing, name: "Thing"
  #       found = Thing.find_by_reference thing
  #       expect(found).to eq thing
  #     end
  #     it "finds within a has_many aassociation by string reference"
  #     it "finds within a has_many aassociation by ID"
  #     it "finds within a has_many aassociation by object"
  #   end
end
