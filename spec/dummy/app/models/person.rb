class Person < ApplicationRecord
  belongs_to :category
  has_name
end
