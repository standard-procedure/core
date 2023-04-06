class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.belongs_to :parent
      t.string :name
      t.string :plural
      t.timestamps
    end
  end
end
