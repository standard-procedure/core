module StandardProcedure
  module HasDescription
    extend ActiveSupport::Concern

    class_methods do
      def has_description
        has_rich_text :description
        delegate :to_s, to: :description, prefix: true
      end
    end
  end
end
