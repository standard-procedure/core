class CreateStandardProcedureCommandLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_command_links do |t|
      t.belongs_to :command, foreign_key: {to_table: :standard_procedure_commands}
      t.belongs_to :item, polymorphic: true, index: true
      t.timestamps
    end
  end
end
