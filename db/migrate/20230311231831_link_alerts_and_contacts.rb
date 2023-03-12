class LinkAlertsAndContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_alert_contacts_links, id: false do |t|
      t.belongs_to :alert, foreign_key: { to_table: :standard_procedure_alerts }
      t.belongs_to :contact,
                   foreign_key: {
                     to_table: :standard_procedure_folder_items,
                   }
    end
  end
end
