class CreateStandardProcedureAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_accounts do |t|
      t.string :reference, null: false, default: ""
      t.string :name, null: false, default: "", unique: true
      t.string :type, null: false, default: ""
      t.text :field_data, limit: 16.megabytes
      t.text :configuration, limit: 16.megabytes
      t.date :active_from, null: false
      t.date :active_until, null: false
      t.timestamps
    end
  end
end
