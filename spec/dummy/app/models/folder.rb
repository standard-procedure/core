class Folder < ApplicationRecord
  belongs_to :parent, class_name: "Folder", optional: true
  has_many :children, class_name: "Folder", foreign_key: "parent_id"
  has_many :documents
  logs_actions
  validates :name, presence: true

  define_command :build_document do |**params|
    documents.create! params
  end
end
