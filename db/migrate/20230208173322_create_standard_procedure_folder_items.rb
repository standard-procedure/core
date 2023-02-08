class CreateStandardProcedureFolderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_folder_items do |t|
      t.belongs_to :folder, foreign_key: { to_table: :standard_procedure_folders }
      t.belongs_to :contents, polymorphic: true, index: true
      t.string :reference, null: false, default: ""
      t.string :name, null: false, default: ""
      t.string :type, null: false, default: ""
      t.text :field_data, limit: 16.megabytes
      t.timestamps
    end
  end
end
