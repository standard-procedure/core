class CreateStandardProcedureNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_notifications do |t|
      t.belongs_to :contact,
        foreign_key: {
          to_table: :standard_procedure_folders
        }
      t.string :type, null: false, default: ""
      t.datetime :sent_at
      t.datetime :acknowledged_at
      t.integer :notification_type, default: 0, null: false
      t.timestamps
    end
  end
end
