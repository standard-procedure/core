module StandardProcedure
  class MessageLink < ApplicationRecord
    belongs_to :message, class_name: "StandardProcedure::Message"
    belongs_to :item, polymorphic: true
  end
end
