class CreateStandardProcedureActionLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_action_links do |t|
      t.belongs_to :action, foreign_key: { to_table: :standard_procedure_actions }
      t.belongs_to :item, polymorphic: true, index: true
      t.timestamps
    end
  end
end
