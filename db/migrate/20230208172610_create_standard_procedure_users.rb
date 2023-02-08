class CreateStandardProcedureUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_users do |t|
      t.string :reference, null: false, default: "", unique: true
      t.string :name, null: false, default: ""
      t.string :type, null: false, default: ""
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end
  end
end
