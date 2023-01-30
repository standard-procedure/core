module StandardProcedure
  module HasReference
    extend ActiveSupport::Concern

    class_methods do
      # USAGE:
      # `has_reference(length: 4, prefix: nil, copy_to: nil)`
      #
      # Example:
      #   `has_reference(length: 2, prefix: "Hello")`
      #     `=> "Hello-ABCD-1234"`
      #
      # This expects the model to have a string field called `reference`
      # and, optionally, a string field called `title`.
      #
      # A reference is automatically generated, using `length` 4-character sections,
      # unless a reference is already provided.  If a prefix is provided then this is added
      # to the beginning of the reference.
      #
      # If `copy_to` is supplied,
      # then the reference is automatically copied to the given field (if it is blank).
      # For example `has_reference copy_to: :title` will copy the reference to the `title` field
      def has_reference(length: 4, prefix: nil, copy_to: nil)
        validates :reference, presence: true, uniqueness: { case_sensitive: false }
        before_validation :set_reference

        define_method :generate_reference_value do
          ([prefix] + (1..4).collect { |i| 4.random_letters.upcase }).compact.join("-")
        end

        define_method :set_reference do
          self.reference = generate_reference_value if reference.blank?
          self.send :"#{copy_to}=", reference if copy_to.present? && self.send(copy_to.to_sym).blank?
        end

        define_method :to_param do
          "#{self.id}-#{self.reference}".parameterize
        end
      end
    end
  end
end
