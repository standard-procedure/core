module StandardProcedure
  class Contact < ApplicationRecord
    has_fields
    belongs_to :user, class_name: "StandardProcedure::User"
    belongs_to :group, class_name: "StandardProcedure::Group"
    delegate :account, to: :group

    command :transfer do |user, params|
    end
  end
end
