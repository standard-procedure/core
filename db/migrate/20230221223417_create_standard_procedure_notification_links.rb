class CreateStandardProcedureNotificationLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_notification_links do |t|
      t.belongs_to :notification, foreign_key: { to_table: :standard_procedure_notifications }
      t.belongs_to :item, polymorphic: true, index: true
      t.timestamps
    end
  end
end
