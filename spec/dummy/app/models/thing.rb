class Thing < ApplicationRecord
  has_name
  has_fields
  belongs_to :category
end
