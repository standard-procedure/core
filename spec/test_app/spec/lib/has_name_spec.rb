require_relative "../rails_helper"

RSpec.describe StandardProcedure::HasName do
  let(:category) { Category.create name: "Something" }

  describe "has_name" do
    before do
      Category.class_eval do
        has_name
      end
    end
    it "ensures that a name is supplied" do
      category.name = ""
      expect(category).to_not be_valid
    end
    it "redefines to_s" do
      expect(category.to_s).to eq "Something"
    end
    it "redefines to_param" do
      expect(category.to_param).to eq "#{category.id}-something"
    end
    it "sorts by name" do
      category.touch
      other_category = Category.create(name: "Aadvark")
      categories = Category.in_name_order
      expect(categories.first).to eq other_category
      expect(categories.last).to eq category
    end
  end
end
