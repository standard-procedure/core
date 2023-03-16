class CreateStandardProcedureRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_roles do |t|
      t.belongs_to :account, foreign_key: {to_table: :standard_procedure_accounts}
      t.string :reference, null: false, default: ""
      t.string :name, null: false, default: ""
      t.string :plural, null: false, default: ""
      t.integer :access_level, default: 0, null: false
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end
  end
end
