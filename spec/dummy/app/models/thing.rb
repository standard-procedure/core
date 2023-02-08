class Thing < ApplicationRecord
  belongs_to :category
  logs_actions
end
