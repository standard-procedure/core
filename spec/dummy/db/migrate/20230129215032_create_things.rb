class CreateThings < ActiveRecord::Migration[7.0]
  def change
    create_table :things do |t|
      t.belongs_to :category
      t.belongs_to :person
      t.string :name
      t.string :reference
      t.text :field_data
      t.timestamps
    end
  end
end
