class CreateStandardProcedureWorkflows < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_workflows do |t|
      t.belongs_to :account, polymorphic: true, index: true
      t.string :reference, null: false, default: ""
      t.string :name, null: false, default: ""
      t.string :type, null: false, default: "StandardProcedure::Workflow"
      t.string :icon, null: false, default: "workflow"
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end
  end
end
