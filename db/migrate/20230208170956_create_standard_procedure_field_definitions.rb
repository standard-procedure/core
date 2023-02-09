class CreateStandardProcedureFieldDefinitions < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_field_definitions do |t|
      t.belongs_to :definable, polymorphic: true, index: true
      t.string :reference, null: false, default: ""
      t.string :name, null: false, default: ""
      t.integer :position, default: 1, null: false
      t.string :type, null: false, limit: 128
      t.text :default_value
      t.text :calculated_value
      t.text :options
      t.text :field_data, limit: 16.megabytes
      t.boolean :mandatory, default: false, null: false
      t.integer :visible_to, default: 0, null: false
      t.integer :editable_by, default: 0, null: false
      t.timestamps
    end
  end
end
