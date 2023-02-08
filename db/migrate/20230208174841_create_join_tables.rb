class CreateJoinTables < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_managers, id: false do |t|
      t.belongs_to :account, foreign_key: { to_table: standard_procedure_accounts }
      t.belongs_to :user, foreign_key: { to_table: standard_procedure_users }
    end
    create_table :standard_procedure_related_items, id: false do |t|
      t.belongs_to :workflow_item, foreign_key: { to_table: standard_procedure_workflow_items }
      t.belongs_to :folder_item, foreign_key: { to_table: standard_procedure_folder_items }
    end
  end
end
