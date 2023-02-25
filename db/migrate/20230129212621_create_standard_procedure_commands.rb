class CreateStandardProcedureCommands < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_commands do |t|
      t.belongs_to :context, index: true
      t.belongs_to :user, polymorphic: true, index: true
      t.belongs_to :target, polymorphic: true, index: true
      t.string :command, limit: 128, null: false, index: true
      t.integer :status, default: 0, null: false
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end
  end
end
