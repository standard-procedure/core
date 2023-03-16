class Category < ApplicationRecord
  has_field_definitions
  has_plural
  # has_ancestors
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: "parent_id"
  has_many :things
end
