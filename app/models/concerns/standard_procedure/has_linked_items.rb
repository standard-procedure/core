module StandardProcedure
  module HasLinkedItems
    extend ActiveSupport::Concern

    class_methods do
      # Create a dynamic, polymorphic HABTM style association using an intermediary class
      #
      # Example:
      # The Notification class can be linked to many Users and many Contacts.
      # And each User or Contact can be linked to many Notifications.
      # So you could have two has_and_belongs_to_many relationships
      #
      # `Notification.has_and_belongs_to_many :users`
      # `Notification.has_and_belongs_to_many :contacts`
      #
      # or you could use a single polymorphic collection via a intermediary link_table:
      #
      # `has_linked :people`
      #
      # Which, when the default parameters are worked out, is equivalent to:
      #   `has_linked :people, class_name: "NotificationLink", through: :linked_people, source: :person
      #
      # This generates an association with the intermediatery class:
      #   `has_many :linked_people, class_name: "NotificationLink", dependent: :destroy`
      #
      # And adds the following methods:
      #   `linked_to? item`
      #   `link_to item`
      #   `unlink_from item`
      #   `link_for item` - the intermediate link for the given item
      #   `linked klass` - all linked instances of the given class
      # This is a fully polymorphic collection - so you're not limited to just Usesrs and Contacts - you
      # could add an Invoice or Customer or whatever if you wanted.
      #
      # You need to define the intermediate class, which in this example, would look like this:
      #
      # ```
      #   class NotificationLink
      #     belongs_to :notification
      #     belongs_to :person, polymorphic: true
      #   end
      # ```
      #
      # The link table would look like this:
      # ```
      #   create_table :notification_links do |t|
      #     t.belongs_to :notification, foreign_key: true
      #     t.belongs_to :person, polymorphic: true, index: true
      #   end
      # ```
      #
      # And the Contact and User classes would use `is_linked_to` to define their side of the association.
      #
      # If you want to keep quick access to both Contacts and Users, you can specify accessors:
      # `has_linked :people, accessing: ["Contact", "User"]`
      # which adds:
      # `contact, contacts, contact=, contacts=`
      # and
      # `user, users, user=, users=`
      #
      # Params:
      #   link_name - the name of the collection of linked objects on the "other side" of the intermediary
      #   class_name - the class representing the link table
      #   source - the attribute on the intermediary class that holds the target model
      #   through - the name of the association holding the intermediary class
      #   accessing - an array of classes for pre-defined accessors
      #
      def has_linked(link_name, class_name: nil, through: nil, source: nil, accessing: [])
        singular_link_name = link_name.to_s.singularize
        class_name ||= "#{model_name}Link"
        klass = class_name.constantize
        source ||= :"#{singular_link_name}"
        through ||= :"linked_#{link_name.to_s.pluralize}"

        has_many_association_name = through

        self.has_many has_many_association_name, class_name: class_name, dependent: :destroy

        define_method :link_for do |item|
          self.send(has_many_association_name).find_by(source => item)
        end

        define_method :linked_to? do |item|
          link_for(item).present?
        end

        define_method :link_to do |item|
          return if item.blank? || item.destroyed? || linked_to?(item)
          self.send(has_many_association_name).build(source => item).tap do |link|
            link.save! unless self.new_record?
          end
        end

        define_method :unlink_from do |item|
          link_for(item)&.destroy
        end

        define_method :linked do |klass|
          class_name = klass.to_s
          type_field = :"#{singular_link_name}_type"
          id_field = :"#{singular_link_name}_id"
          ids = self.send(has_many_association_name).where(type_field => class_name).pluck(id_field).uniq
          klass.where(id: ids)
        end

        Array.wrap(accessing).each do |class_name|
          klass = class_name.to_s.constantize
          singular = klass.model_name.singular.to_sym
          plural = klass.model_name.plural.to_sym

          define_method plural do
            linked(klass)
          end

          define_method :"#{plural}=" do |models|
            models.each { |m| link_to(m) }
          end

          define_method singular do
            linked(klass).first
          end

          define_method :"#{singular}=" do |model|
            link_to model
          end
        end
      end

      # Build a HABTM style polymorphic association between this model and a destination model - the inverse of `has_linked`
      # Params:
      #   association: the name of the association to access the destination models - for example `is_linked_to :notifications`
      #   class_name: the name of the destination model - if the association is :notifications then this defaults to Notification
      #   intermediary_class_name: the name of the intermediary class - if the association is :notifications then this defaults to "NotificationLink"
      #   intermediary_association: the name of the association to access the intermediaries - if the association is :notifications then this defaults to :notification_links
      #   as: the attribute on the intermediary class to access this model - this defaults to :item
      # If `is_linked_to :notifications` is called, this will add two associations:
      #   has_many :notification_links, class_name: "NotificationLink", as: :item, dependent: :destroy
      #   has_many :notifications, through: :notification_links
      def is_linked_to(association, class_name: nil, intermediary_class_name: nil, intermediary_association: nil, as: :item)
        singular_association = association.to_s.singularize
        class_name ||= association.to_s.singularize.camelize
        intermediary_class_name ||= "#{class_name}Link"
        intermediary_association ||= intermediary_class_name.demodulize.tableize.to_sym

        has_many intermediary_association, class_name: intermediary_class_name, as: as, dependent: :destroy
        has_many association.to_sym, -> { order(:created_at).distinct }, class_name: class_name, through: intermediary_association, source: singular_association.to_sym
      end
    end
  end
end
