class Thing < ApplicationRecord
  has_name
  has_fields
  belongs_to :category
  belongs_to :person, optional: true
end
