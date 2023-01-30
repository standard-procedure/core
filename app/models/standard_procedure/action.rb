module StandardProcedure
  class Action < ApplicationRecord
    belongs_to :context, class_name: "StandardProcedure::Action", optional: true
    belongs_to :user, polymorphic: true
    belongs_to :target, polymorphic: true
    has_many :follow_on_actions, class_name: "StandardProcedure::Action", foreign_key: "context_id", dependent: :nullify
    has_fields
    has_hash :params
    has_linked :items
    validates :command, presence: true
    after_save :build_links

    def to_s
      command
    end

    def result
      params["result"]
    end

    protected

    def build_links
      link_to user
      link_to target
    end
  end
end
