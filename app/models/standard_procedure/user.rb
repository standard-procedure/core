module StandardProcedure
  class User < ApplicationRecord
    is_user
    has_reference
    has_name
    has_many :contacts, class_name: "StandardProcedure::Contact", dependent: :destroy
  end
end
