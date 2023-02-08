module StandardProcedure
  class Folder < ApplicationRecord
    has_name
    has_ancestors
    has_reference
    has_fields
    belongs_to :account, class_name: "StandardProcedure::Account"
    belongs_to :parent, class_name: "StandardProcedure::Folder", optional: true
    has_many :children, class_name: "StandardProcedure::Folder", foreign_key: "parent_id", dependent: :destroy
  end
end
