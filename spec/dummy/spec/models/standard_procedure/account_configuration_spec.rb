require "rails_helper"

module StandardProcedure
  RSpec.describe Account, type: :model do
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

      describe "groups" do
        class ::Organisation < StandardProcedure::Group
        end

        let :standard_configuration do
          <<-YAML
            groups:
              - reference: organisations
                name: Organisation
                fields:
                  - reference: address
                    name: Address
                    type: StandardProcedure::FieldDefinition::Address
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
        it "creates groups based on the type provided" do
          account = a_saved Account
          account.configure_from custom_configuration
          group = account.groups.find_by reference: "organisations"
          expect(group).to_not be_nil
          expect(group.model_name.to_s).to eq "Organisation"
        end
        it "adds fields to the group" do
          account = a_saved Account
          account.configure_from standard_configuration
          group = account.groups.find_by reference: "organisations"
          address_field = group.field_definitions.find_by reference: "address"
          expect(address_field).to_not be_nil
          expect(address_field.model_name.to_s).to eq "StandardProcedure::FieldDefinition::Address"
        end
      end
      describe "roles" do
        let :standard_configuration do
          <<-YAML
            roles:
              - reference: managers
                name: Manager
                access_level: administrator
              - reference: staff
                name: Staff member
                fields:
                  - reference: ni_number
                    name: NI Number
                    type: StandardProcedure::FieldDefinition::Text
              - reference: customers
                name: Customer
                access_level: restricted
          YAML
        end
        it "adds roles to the account" do
          account = a_saved Account
          account.configure_from standard_configuration
          managers = account.roles.find_by reference: "managers"
          expect(managers).to_not be_nil
          expect(managers.plural).to eq "Managers"
          expect(managers).to be_administrator
          staff = account.roles.find_by reference: "staff"
          expect(staff).to_not be_nil
          expect(staff.plural).to eq "Staff members"
          expect(staff).to be_standard
          customers = account.roles.find_by reference: "customers"
          expect(customers).to_not be_nil
          expect(customers.plural).to eq "Customers"
          expect(customers).to be_restricted
        end
        it "does not replace existing roles" do
          account = a_saved Account
          clients = account.roles.create reference: "customers", name: "Client"
          account.configure_from standard_configuration
          customers = account.roles.find_by reference: "customers"
          expect(clients).to eq customers
          expect(customers.name).to eq "Client"
        end
        it "adds fields to the role" do
          account = a_saved Account
          account.configure_from standard_configuration
          staff = account.roles.find_by reference: "staff"
          ni_field = staff.field_definitions.find_by reference: "ni_number"
          expect(ni_field).to_not be_nil
          expect(ni_field.model_name.to_s).to eq "StandardProcedure::FieldDefinition::Text"
        end
      end
      describe "workflows" do
        class ::Board < StandardProcedure::Workflow
        end

        class ::DisciplinaryStatus < StandardProcedure::WorkflowStatus
        end

        let :standard_configuration do
          <<-YAML
            workflows:
              - reference: disciplinaries
                name: Disciplinaries
                statuses:
                  - reference: draft
                    name: Draft
                    position: 1
                    assign_to: 
                      - contact: someone@example.com
                    actions:
                      - reference: postpone
                        name: Postpone
                        type: StandardProcedure::WorkflowItem::Postpone
                      - reference: record_minutes
                        name: Record Minutes
                        type: Disciplinary::RecordMinutes                          
                  - reference: hearing_complete
                    name: Hearing Complete
                    position: 2
            YAML
        end
        let :custom_configuration do
          <<-YAML
            workflows:
              - reference: disciplinaries
                name: Disciplinaries
                type: Board
                statuses:
                  - reference: draft
                    name: Draft
                    type: DisciplinaryStatus
          YAML
        end

        it "adds workflows to the account" do
          account = a_saved Account
          account.configure_from standard_configuration
          # Check the workflow was imported
          workflow = account.workflows.find_by reference: "disciplinaries"
          expect(workflow).to_not be_nil
          # Check its statuses were imported
          status = workflow.statuses.find_by reference: "draft"
          expect(status).to_not be_nil
          expect(status.position).to eq 1
          expect(status.assign_to).to eq [{ "contact" => "someone@example.com" }]
          # Check the actions were imported
          postpone = status.actions.first
          expect(postpone).to_not be_nil
          expect(postpone["reference"]).to eq "postpone"
          expect(postpone["name"]).to eq "Postpone"
          expect(postpone["type"]).to eq "StandardProcedure::WorkflowItem::Postpone"
          record_minutes = status.actions.last
          expect(record_minutes).to_not be_nil
          expect(record_minutes["reference"]).to eq "record_minutes"
          expect(record_minutes["name"]).to eq "Record Minutes"
          expect(record_minutes["type"]).to eq "Disciplinary::RecordMinutes"
        end
        it "does not replace existing workflows" do
          account = a_saved Account
          procedures = account.workflows.create reference: "disciplinaries", name: "HR Procedures"
          invited = procedures.statuses.create reference: "draft", name: "Invited to hearing"
          account.configure_from standard_configuration
          workflow = account.workflows.find_by reference: "disciplinaries"
          expect(procedures).to eq workflow
          expect(workflow.name).to eq "HR Procedures"
          status = workflow.statuses.find_by reference: "draft"
          expect(status).to eq invited
          expect(status.name).to eq "Invited to hearing"
        end
        it "creates workflows based on the type provided" do
          account = a_saved Account
          account.configure_from custom_configuration
          workflow = account.workflows.find_by reference: "disciplinaries"
          expect(workflow).to_not be_nil
          expect(workflow.model_name.to_s).to eq "Board"
          status = workflow.statuses.find_by reference: "draft"
          expect(status).to_not be_nil
          expect(status.model_name.to_s).to eq "DisciplinaryStatus"
        end
      end
      describe "templates" do
        class ::CardType < StandardProcedure::WorkflowItemTemplate
        end

        let :standard_configuration do
          <<-YAML
            templates:
              - reference: orders
                name: Order
                fields:
                  - reference: address
                    name: Address
                    type: StandardProcedure::FieldDefinition::Address
          YAML
        end
        let :custom_configuration do
          <<-YAML
            templates:
              - reference: orders
                name: Order
                type: CardType
          YAML
        end

        it "adds templates to the account" do
          account = a_saved Account
          account.configure_from standard_configuration
          template = account.templates.find_by reference: "orders"
          expect(template).to_not be_nil
        end
        it "does not replace existing groups" do
          account = a_saved Account
          sales = account.templates.create reference: "orders", name: "Sales"
          account.configure_from standard_configuration
          template = account.templates.find_by reference: "orders"
          expect(sales).to eq template
          expect(template.name).to eq "Sales"
        end
        it "creates templates based on the type provided" do
          account = a_saved Account
          account.configure_from custom_configuration
          template = account.templates.find_by reference: "orders"
          expect(template).to_not be_nil
          expect(template.model_name.to_s).to eq "CardType"
        end
        it "adds fields to the template" do
          account = a_saved Account
          account.configure_from standard_configuration
          template = account.templates.find_by reference: "orders"
          address_field = template.field_definitions.find_by reference: "address"
          expect(address_field).to_not be_nil
          expect(address_field.model_name.to_s).to eq "StandardProcedure::FieldDefinition::Address"
        end
      end
    end
  end
end
