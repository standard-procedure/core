require "rails_helper"

module StandardProcedure
  RSpec.describe Document, type: :model do
    let(:user) { a_saved ::User }
    let(:account) { a_saved(Account).configure_from(configuration) }
    let(:template) { account.templates.find_by reference: "orders" }
    let(:meetings) { account.templates.find_by reference: "meetings" }
    let(:holidays) { account.templates.find_by reference: "holidays" }
    let(:workflow) { account.workflows.find_by reference: "order_processing" }
    let(:incoming_status) { workflow.statuses.find_by reference: "incoming" }
    let(:in_progress_status) { workflow.statuses.find_by reference: "in_progress" }
    let(:staff) { account.roles.find_by reference: "staff" }
    let(:employees) { account.organisations.find_by reference: "employees" }
    let(:nichola) { a_saved StandardProcedure::Contact, account: account, parent: employees, role: staff, reference: "nichola@example.com" }
    let(:anna) { a_saved StandardProcedure::Contact, account: account, parent: employees, role: staff, reference: "anna@example.com" }
    let :configuration do
      <<-YAML
        roles:
          - reference: staff
            name: Staff
        organisations:
          - reference: employees
            name: Employees
        templates:
          - reference: orders
            name: Order
            fields:
              - reference: supervisor
                name: Supervisor
                type: StandardProcedure::FieldDefinition::Model
                model_type: StandardProcedure::Contact
          - reference: meetings
            name: Meeting
            calendar_type: time
          - reference: holidays
            name: Holiday
            calendar_type: date
        workflows:
          - reference: order_processing
            name: Order Processeing
            statuses:
              - reference: incoming
                name: Incoming
                position: 1
                assign_to:
                  - contact: nichola@example.com
              - reference: in_progress
                name: In Progress
                position: 2
      YAML
    end

    before do
      anna.touch
      nichola.touch
    end

    describe "assignments" do
      subject { a_saved StandardProcedure::Document, folder: employees, status: incoming_status, template: template, name: "Something" }

      it "assigns the item to a contact and notifies them" do
        subject.assign_to contact: nichola, performed_by: user
        expect(subject.assigned_to).to eq nichola
        notification = nichola.notifications.last
        expect(notification).to_not be_nil
        expect(notification.linked_to?(subject)).to eq true
      end
    end

    describe "changing status" do
      subject { a_saved StandardProcedure::Document, folder: employees, status: incoming_status, template: template, name: "Something" }

      it "is updated" do
        subject.set_status reference: "in_progress", performed_by: user
        expect(subject.status).to eq in_progress_status
      end

      it "notifies the status that this item has been updated" do
        expect(in_progress_status).to receive(:document_added).with(performed_by: user, document: subject)
        subject.set_status status: in_progress_status, performed_by: user
      end
    end

    describe "finding contacts" do
      subject { a_saved StandardProcedure::Document, folder: employees, status: incoming_status, template: template, name: "Something" }

      it "returns the given contact" do
        expect(subject.find_contact_from(nichola)).to eq nichola
      end
      it "finds contacts by reference" do
        expect(subject.find_contact_from("nichola@example.com")).to eq nichola
      end
      it "finds the item's contact" do
        folder = Folder.create! parent: nichola, name: "Nichola's orders"
        subject.update folder: folder
        expect(subject.find_contact_from("contact")).to eq nichola
      end
      it "finds contacts by referencing a custom field" do
        subject.with_fields_from(template).update folder: nichola, supervisor: anna
        expect(subject.find_contact_from("supervisor")).to eq anna
      end
    end

    describe "calendars" do
      describe "non-calendar items" do
        subject { a_saved StandardProcedure::Document, folder: employees, status: incoming_status, template: template, name: "Something" }

        it "do not require a date or times" do
          expect(subject.requires_date?).to eq false
          expect(subject.requires_time?).to eq false
          expect(subject.date).to be_nil
          expect(subject.starts_at).to be_nil
          expect(subject.ends_at).to be_nil
        end

        it "does not allow attendees to be invited" do
          expect { subject.invite attendee: nichola, performed_by: user }.to raise_exception(StandardProcedure::Document::NotACalendarItem)
        end
      end

      describe "dated calendar items" do
        subject { a_saved StandardProcedure::Document, folder: employees, status: incoming_status, template: holidays, name: "Something", date: Date.today }

        it "requires a date but no times" do
          expect(subject.requires_date?).to eq true
          expect(subject.requires_time?).to eq false
          expect(subject).to be_valid
        end
        it "is invalid if there is no date set" do
          subject.date = nil
          expect(subject).to_not be_valid
        end
        it "allows attendees to be invited" do
          subject.invite attendee: nichola, performed_by: user
          expect(subject.attendees).to include(nichola)
          expect(nichola.calendar_items).to include(subject)
        end
        it "does not allow an attendee to be invited more than once" do
          subject.invite attendee: nichola, performed_by: user
          expect(subject.attendees.count).to eq 1
          subject.invite attendee: nichola, performed_by: user
          expect(subject.attendees.count).to eq 1
        end
        it "allows an attendee to be removed" do
          subject.invite attendee: nichola, performed_by: user
          subject.deinvite attendee: nichola, performed_by: user
          expect(subject.attendees.count).to eq 0
        end
      end

      describe "timed calendar items" do
        subject { a_saved StandardProcedure::Document, folder: employees, status: incoming_status, template: meetings, name: "Something", date: Date.today, starts_at: "10:00am", ends_at: "12pm" }

        it "requires a date and times" do
          expect(subject.requires_date?).to eq true
          expect(subject.requires_time?).to eq true
          expect(subject).to be_valid
        end
        it "is invalid if there is no date set" do
          subject.date = nil
          expect(subject).to_not be_valid
        end
        it "is invalid if no start time is set" do
          subject.starts_at = nil
          expect(subject).to_not be_valid
        end
        it "is invalid if no end time is set" do
          subject.ends_at = nil
          expect(subject).to_not be_valid
        end
        it "allows attendees to be invited" do
          subject.invite attendee: nichola, performed_by: user
          expect(subject.attendees).to include(nichola)
          expect(nichola.calendar_items).to include(subject)
        end
        it "does not allow an attendee to be invited more than once" do
          subject.invite attendee: nichola, performed_by: user
          expect(subject.attendees.count).to eq 1
          subject.invite attendee: nichola, performed_by: user
          expect(subject.attendees.count).to eq 1
        end
        it "allows an attendee to be removed" do
          subject.invite attendee: nichola, performed_by: user
          subject.deinvite attendee: nichola, performed_by: user
          expect(subject.attendees.count).to eq 0
        end
      end
    end
  end
end
