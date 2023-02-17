require "rails_helper"

module StandardProcedure
  RSpec.describe Account, type: :model do
    describe "contacts" do
      it "adds a contact to the given group"
      it "adds a contact to the given group when given a group reference"
      it "removes a contact"
    end

    describe "configuration" do
      it "does not allow invalid YAML to be loaded" do
        invalid_yaml = <<-YAML
          first_key: first_value
          second_key: second_value
            wrong_key: third_value
          YAML
        account = a_saved Account
        account.configuration = invalid_yaml
        expect(account).to_not be_valid
      end

      describe "roles" do
        let :standard_configuration do
          <<-YAML
            roles:
              - staff 
              - customers
          YAML
        end
        it "knows which additional roles are defined" do
          account = a_saved Account
          account.configure_from standard_configuration
          expect(account.roles).to include "staff"
          expect(account.roles).to include "customers"
        end
        it "has predefined admin and restricted roles" do
          account = a_saved Account
          expect(account.roles).to include "admin"
          expect(account.roles).to include "restricted"
        end
      end

      describe "groups" do
        class ::Organisation < StandardProcedure::Group
        end

        let :standard_configuration do
          <<-YAML
            groups:
              - reference: organisations
                name: Organisation
          YAML
        end
        let :custom_configuration do
          <<-YAML
            groups:
              - reference: organisations
                name: Organisation
                type: Organisation
          YAML
        end

        it "adds groups to the account" do
          account = a_saved Account
          account.configure_from standard_configuration
          group = account.groups.find_by reference: "organisations"
          expect(group).to_not be_nil
        end
        it "does not replace existing groups" do
          account = a_saved Account
          suppliers = account.groups.create reference: "organisations", name: "Supplier"
          account.configure_from standard_configuration
          group = account.groups.find_by reference: "organisations"
          expect(suppliers).to eq group
          expect(suppliers.name).to eq "Supplier"
        end
        it "creates groups based on the type provided"
      end
    end
  end
end
