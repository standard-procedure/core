module StandardProcedure
  class Contact < ApplicationRecord
    has_fields
    belongs_to :user, class_name: "StandardProcedure::User", optional: true
    belongs_to :group, class_name: "StandardProcedure::Group"
    belongs_to :role, class_name: "StandardProcedure::Role"
    has_and_belongs_to_many :alerts, class_name: "StandardProcedure::Alert"
    delegate :account, to: :role
    delegate :access_level, to: :role

    command :transfer do |user, params|
    end
  end
end
