require "rails_helper"

module StandardProcedure
  RSpec.describe WorkflowItemTemplate, type: :model do
    describe "adding items" do
      subject { account.templates.find_by reference: "order" }
      let(:user) { a_saved ::User }
      let(:account) { a_saved(Account).configure_from(configuration) }
      let(:customers) { account.groups.find_by reference: "customers" }
      let(:role) { account.roles.find_by reference: "customer" }
      let(:workflow) { account.workflows.find_by reference: "order_processing" }
      let(:incoming_status) { workflow.statuses.find_by reference: "incoming" }
      let :configuration do
        <<-YAML
          templates:
            - reference: order
              name: Order
          roles:
            - reference: customer
              name: Customer
          groups:
            - reference: customers
              name: Customer
          workflows:
            - reference: order_processing
              name: Order Processeing
              statuses:
                - reference: incoming
                  name: Incoming
                  position: 1
                  deadlines:
                    - hours: 48
                      type: StandardProcedure::Deadline::SendNotification
                      contacts:
                        - anna@example.com
                          nichola@example.com
                - reference: in_progress
                  name: In Progress
                  position: 2
        YAML
      end
      it "tells the status that the item has been added" do
        expect(incoming_status).to receive(:item_added)
        subject.add_item name: "Order 123",
                         group: customers,
                         status: incoming_status,
                         performed_by: user
      end
      it "uses the contact's group from the contact if no group is provided" do
        contact =
          account.add_contact group: customers,
                              name: "Some person",
                              role: role,
                              performed_by: user
        item =
          subject.add_item name: "Order 123",
                           contact: contact,
                           status: incoming_status,
                           performed_by: user
        expect(item.group).to eq customers
      end
      it "uses the initial status if the workflow is provided" do
        item =
          subject.add_item name: "Order 123",
                           group: customers,
                           workflow: workflow,
                           performed_by: user
        expect(item.status).to eq incoming_status
      end
    end
  end
end
