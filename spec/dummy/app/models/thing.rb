class Thing < ApplicationRecord
  has_name
  has_field_values
  belongs_to :category
end
