class CreateStandardProcedureAlerts < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_alerts do |t|
      t.belongs_to :item, polymorphic: true, index: true
      t.string :type, null: false, default: ""
      t.datetime :due_at, null: false, index: true
      t.datetime :triggered_at
      t.integer :status, default: 0, null: false
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end

    create_join_table :standard_procedure_alerts, :standard_procedure_contacts
  end
end
