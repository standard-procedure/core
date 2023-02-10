module StandardProcedure
  class Contact < ApplicationRecord
    has_fields
    belongs_to :user, class_name: "StandardProcedure::User"
    belongs_to :group, class_name: "StandardProcedure::Group"
    has_and_belongs_to_many :management_roles, class_name: "StandardProcedure::Account", join_table: "standard_procedure_managers", association_foreign_key: "account_id", foreign_key: "manager_id"

    command :transfer do |user, params|
    end
  end
end
