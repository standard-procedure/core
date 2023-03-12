class CreateStandardProcedureFolderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_folder_items do |t|
      t.belongs_to :folder,
                   foreign_key: {
                     to_table: :standard_procedure_folders,
                   }
      t.belongs_to :owner,
                   foreign_key: {
                     to_table: :standard_procedure_folders,
                   }
      t.integer :position, default: 1, null: false
      t.integer :item_status, default: 0, null: false

      t.string :reference, null: false, default: ""
      t.string :name, null: false, default: ""
      t.string :type, null: false, default: ""
      t.text :field_data, limit: 16.megabytes

      t.belongs_to :template,
                   foreign_key: {
                     to_table: :standard_procedure_document_templates,
                   }
      # Workflow Item fields
      t.belongs_to :status,
                   foreign_key: {
                     to_table: :standard_procedure_workflow_statuses,
                   }
      t.belongs_to :assigned_to,
                   foreign_key: {
                     to_table: :standard_procedure_folders,
                   }
      t.timestamps
    end
  end
end
