class CreateStandardProcedureContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_contacts do |t|
      t.belongs_to :user, foreign_key: { to_table: :standard_procedure_users }
      t.belongs_to :group, foreign_key: { to_table: :standard_procedure_groups }
      t.string :role, limit: 64, default: "", null: false
      t.string :reference, null: false, default: ""
      t.string :name, null: false, default: "" # denormalised from user for speed
      t.string :type, null: false, default: ""
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end
  end
end
