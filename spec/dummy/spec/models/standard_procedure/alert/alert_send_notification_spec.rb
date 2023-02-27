require "rails_helper"

module StandardProcedure
  RSpec.describe Alert::SendNotification, type: :model do
    let(:account) { a_saved Account }
    let(:item) { a_saved_item_titled "Something", account: account }
    let(:alice) { a_saved_contact_called "Alice", account: account }
    let(:bob) { a_saved_contact_called "Bob", account: account }
  end
end
