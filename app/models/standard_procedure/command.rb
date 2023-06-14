module StandardProcedure
  class Command < ApplicationRecord
    belongs_to :context, class_name: "StandardProcedure::Command", optional: true
    belongs_to :user, polymorphic: true, optional: true
    belongs_to :target, polymorphic: true, optional: true
    has_many :follow_on_commands, class_name: "StandardProcedure::Command", foreign_key: "context_id", dependent: :nullify
    enum status: {ready: 0, in_progress: 10, completed: 100, failed: -1}
    has_fields
    has_field :job_id
    has_hash :params
    has_field :error
    has_linked :items, class_name: "StandardProcedure::CommandLink"
    validates :command, presence: true
    after_save :link_related_items

    scope :roots, -> { where(context: nil) }
    scope :in_order, -> { order "updated_at desc" }

    def to_s
      command
    end

    def human_name
      command.to_s.underscore.humanize.sub(" job", "")
    end

    def human_params
      humanise(params).join(", ")
    end

    def humanise hash
      hash.map do |key, value|
        if value.is_a? Array
          "#{key.to_s.humanize}: #{value.map(&:to_s).join(", ")}"
        elsif value.is_a? Hash
          "#{key.to_s.humanize}: #{humanise(value).join(", ")}"
        else
          [key.to_s.humanize, value.to_s]
        end
      end
    end

    def date
      updated_at.to_date
    end

    def result
      params[:result]
    end

    def error
      params[:error]
    end

    class << self
      def context_stack
        Thread.current[:context_stack] ||= []
      end

      def context
        context_stack.last
      end
    end

    protected

    def link_related_items
      link_to user
      link_to target
      params.each do |key, value|
        link_to value if value.is_a? ActiveRecord::Base
      end
    end
  end
end
