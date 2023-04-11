module StandardProcedure
  module HasName
    extend ActiveSupport::Concern

    class_methods do
      def has_name
        scope :in_name_order, -> { order :name }
        validates :name, presence: true
        define_method :to_s do
          name
        end
        define_method :to_param do
          "#{id}-#{name}".parameterize
        end
      end

      def has_plural
        validates :plural, presence: true
        before_validation :set_plural

        define_method :set_plural do
          self.plural = name.to_s.pluralize if plural.blank?
        end
      end
    end
  end
end
