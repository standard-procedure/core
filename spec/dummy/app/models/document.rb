class Document < ApplicationRecord
  belongs_to :folder
  logs_actions
  validates :name, presence: true
end
