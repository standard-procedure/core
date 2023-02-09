class CreateStandardProcedureFolders < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_folders do |t|
      t.belongs_to :account, foreign_key: { to_table: :standard_procedure_accounts }
      t.belongs_to :parent, foreign_key: { to_table: :standard_procedure_folders }
      t.belongs_to :group, foreign_key: { to_table: :standard_procedure_groups }
      t.belongs_to :contact, foreign_key: { to_table: :standard_procedure_contacts }
      t.string :reference, null: false, default: ""
      t.string :name, null: false, default: ""
      t.string :type, null: false, default: ""
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end
  end
end
