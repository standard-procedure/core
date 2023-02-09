module StandardProcedure
  class Folder < ApplicationRecord
    has_name
    has_ancestors
    has_reference
    has_fields
    belongs_to :account, class_name: "StandardProcedure::Account"
    belongs_to :parent, class_name: "StandardProcedure::Folder", optional: true
    belongs_to :group, class_name: "StandardProcedure::Group", optional: true
    belongs_to :contact, class_name: "StandardProcedure::Contact", optional: true
    has_many :sub_folders, class_name: "StandardProcedure::Folder", foreign_key: "parent_id", dependent: :destroy
  end
end
