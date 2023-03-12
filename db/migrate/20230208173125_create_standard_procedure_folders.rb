class CreateStandardProcedureFolders < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_folders do |t|
      t.string :reference, null: false, default: ""
      t.string :name, null: false, default: ""
      t.string :type, null: false, default: ""
      t.string :ancestry, null: false, index: true
      t.integer :ancestry_depth, null: false, default: 0

      t.belongs_to :account,
                   foreign_key: {
                     to_table: :standard_procedure_accounts,
                   }

      t.text :field_data, limit: 16.megabytes

      # Contact defailts
      t.belongs_to :role, foreign_key: { to_table: :standard_procedure_roles }
      t.timestamps
    end
  end
end
