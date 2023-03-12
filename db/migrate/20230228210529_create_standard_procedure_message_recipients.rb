class CreateStandardProcedureMessageRecipients < ActiveRecord::Migration[7.0]
  def change
    create_table :standard_procedure_message_recipients do |t|
      t.belongs_to :message,
                   foreign_key: {
                     to_table: "standard_procedure_messages",
                   }
      t.belongs_to :recipient,
                   foreign_key: {
                     to_table: "standard_procedure_folders",
                   }
      t.datetime :read_at
      t.timestamps
    end
  end
end
