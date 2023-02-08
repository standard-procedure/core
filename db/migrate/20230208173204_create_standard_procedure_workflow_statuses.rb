class CreateStandardProcedureWorkflowStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_workflow_statuses do |t|
      t.belongs_to :workflow, foreign_key: { to_table: :standard_procedure_workflows }
      t.string :reference, null: false, default: ""
      t.string :name, null: false, default: ""
      t.string :type, null: false, default: ""
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end
  end
end
