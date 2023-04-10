require_relative "../rails_helper"

RSpec.describe StandardProcedure::HasLogo do
  let(:category) { Category.create name: "Something" }

  describe "has_logo" do
    before do
      Category.class_eval do
        has_logo
      end
    end
    it "adds a logo attachment" do
      expect(category).to respond_to(:logo)
      expect(category).to respond_to(:logo_url)
    end
  end
  describe "has_image" do
    before do
      Category.class_eval do
        has_image
      end
    end
    it "adds an image attachment" do
      expect(category).to respond_to(:image)
      expect(category).to respond_to(:image_url)
    end
  end
  describe "has arbitrary attachment" do
    before do
      Category.class_eval do
        has_attachment_called :something
      end
    end
    it "adds a named attachment" do
      expect(category).to respond_to(:something)
      expect(category).to respond_to(:something_url)
    end
  end
end
