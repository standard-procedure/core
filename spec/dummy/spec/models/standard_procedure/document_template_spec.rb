require "rails_helper"

module StandardProcedure
  RSpec.describe DocumentTemplate, type: :model do
    describe "adding items" do
      subject { account.templates.find_by reference: "order" }
      let(:user) { a_saved ::User }
      let(:account) { a_saved(Account).configure_from(configuration) }
      let(:customers) { account.organisations.find_by reference: "customers" }
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
          organisations:
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
      it "tells the status that the document has been added" do
        expect(incoming_status).to receive(:document_added)
        subject.create_document name: "Order 123", folder: customers, status: incoming_status, performed_by: user
      end
      it "uses the contact's organisation if no organisation is provided" do
        contact = account.add_contact organisation: customers, name: "Some person", role: role, performed_by: user
        folder = contact.add_folder name: "Folder", performed_by: user
        document = subject.create_document name: "Order 123", folder: folder, status: incoming_status, performed_by: user
        puts document.folder.path.pluck(:name).join("/")
        expect(document.organisation).to eq customers
        expect(document.contact).to eq contact
      end
      it "uses the initial status if the workflow is provided" do
        document = subject.create_document name: "Order 123", folder: customers, workflow: workflow, performed_by: user
        expect(document.status).to eq incoming_status
      end
    end
  end
end
