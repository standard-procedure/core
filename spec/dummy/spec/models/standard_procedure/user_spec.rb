require "rails_helper"

module StandardProcedure
  RSpec.describe User, type: :model do
    subject { a_saved User, name: "Annie" }
    let(:first_account) { a_saved(Account) }
    let(:first_anna) do
      a_saved_contact_called "Anna", account: first_account, user: subject
    end
    let(:second_account) { a_saved(Account) }
    let(:second_anna) do
      a_saved_contact_called "Anna M", account: second_account, user: subject
    end

    it "updates all contacts with its name" do
      first_anna.touch
      second_anna.touch

      subject.amend name: "Anna-Maria", performed_by: User.root

      expect(first_anna.reload.name).to eq "Anna-Maria"
      expect(second_anna.reload.name).to eq "Anna-Maria"
    end

    it "knows when it is detached" do
      expect(subject).to be_detached
    end

    it "attaches itself to a contact" do
      second_anna.update user: nil
      expect(subject.contacts).to_not include(second_anna)

      subject.attach access_code: second_anna.access_code, performed_by: subject
      expect(subject.contacts).to_not include(second_anna)
    end
  end
end
