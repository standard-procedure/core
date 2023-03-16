class CreateStandardProcedureFolders < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_folders do |t|
      t.string :reference, null: false, default: ""
      t.string :name, null: false, default: ""
      t.string :type, null: false, default: ""
      t.string :ancestry, null: false, default: "", index: true
      t.integer :ancestry_depth, null: false, default: 0

      t.belongs_to :account,
        foreign_key: {
          to_table: :standard_procedure_accounts
        }

      t.text :field_data, limit: 16.megabytes

      # Contact fields
      t.belongs_to :user, foreign_key: {to_table: :standard_procedure_users}
      t.belongs_to :role, foreign_key: {to_table: :standard_procedure_roles}
      t.string :access_code, default: "", null: false, index: true
      t.timestamps
    end
  end
end
