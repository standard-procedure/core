require "rails_helper"

module StandardProcedure
  RSpec.describe Contact, type: :model do
    describe "roles" do
      it "allows a role of admin"
      it "allows a role of restricted"
      it "does not allow a role that is not defined on the account"
    end
  end
end
