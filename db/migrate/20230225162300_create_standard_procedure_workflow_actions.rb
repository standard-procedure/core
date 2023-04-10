class CreateStandardProcedureWorkflowActions < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_workflow_actions do |t|
      t.belongs_to :performed_by, polymorphic: true
      t.belongs_to :document, polymorphic: true
      t.string :type, null: false, default: ""
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end
  end
end
