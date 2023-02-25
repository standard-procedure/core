class CreateStandardProcedureWorkflowActions < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_workflow_actions do |t|
      t.belongs_to :user, foreign_key: { to_table: :standard_procedure_users }
      t.belongs_to :item, foreign_key: { to_table: :standard_procedure_workflow_items }
      t.string :type, null: false, default: ""
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end
  end
end
