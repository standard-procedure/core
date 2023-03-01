class CreateStandardProcedureMessageLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_message_links do |t|
      t.belongs_to :message, foreign_key: { to_table: :standard_procedure_messages }
      t.belongs_to :item, polymorphic: true, index: true
      t.timestamps
    end
  end
end
