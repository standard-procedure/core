class LinkCalendarItemsAndContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_calendar_item_attendees, id: false do |t|
      t.bigint :calendar_item_id
      t.bigint :attendee_id
    end

    add_index :standard_procedure_calendar_item_attendees, :calendar_item_id, name: "calendar_item_attendees"
    add_index :standard_procedure_calendar_item_attendees, :attendee_id, name: "attendee_calendar_items"
  end
end
