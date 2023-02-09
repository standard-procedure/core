class CreateStandardProcedurePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_permissions do |t|
      t.string :type, null: false, default: ""
      t.belongs_to :owner, polymorphic: true, index: true
      t.belongs_to :restricted, polymorphic: true, index: true
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end
  end
end
