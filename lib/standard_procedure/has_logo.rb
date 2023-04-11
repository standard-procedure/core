module StandardProcedure
  module HasLogo
    extend ActiveSupport::Concern

    class_methods do
      def has_attachment_called(name)
        has_one_attached name
        delegate :url, to: name, prefix: true
      end

      def has_logo
        has_attachment_called :logo
      end

      def has_image
        has_attachment_called :image
      end
    end
  end
end
