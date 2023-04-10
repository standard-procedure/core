class CreateStandardProcedureMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_messages do |t|
      t.belongs_to :sender, polymorphic: true, index: true
      t.string :subject, default: "", null: false
      t.timestamps
    end
  end
end
