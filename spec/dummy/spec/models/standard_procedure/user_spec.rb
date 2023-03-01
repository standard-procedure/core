require "rails_helper"

module StandardProcedure
  RSpec.describe User, type: :model do
    subject { a_saved ::User, name: "Annie" }
    let(:first_account) { a_saved(Account) }
    let(:first_anna) { a_saved_contact_called "Anna", account: first_account, user: subject }
    let(:second_account) { a_saved(Account) }
    let(:second_anna) { a_saved_contact_called "Anna M", account: second_account, user: subject }

    it "updates all contacts with its name" do
      first_anna.touch
      second_anna.touch

      subject.amend User.root, name: "Anna-Maria"

      expect(first_anna.reload.name).to eq "Anna-Maria"
      expect(second_anna.reload.name).to eq "Anna-Maria"
    end
  end
end
