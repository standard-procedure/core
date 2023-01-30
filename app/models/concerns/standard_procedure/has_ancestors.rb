module StandardProcedure
  module HasAncestors
    extend ActiveSupport::Concern

    class_methods do
      def has_ancestors(parent: :parent, children: :children, foreign_key: nil)
        foreign_key ||= :"#{parent}_id"

        scope :top_level, -> { where(foreign_key => nil) }

        belongs_to parent, class_name: model_name.to_s, foreign_key: foreign_key, optional: true
        has_many children, class_name: model_name.to_s, foreign_key: foreign_key, dependent: :destroy
        has_and_belongs_to_many :ancestors, class_name: model_name.to_s, join_table: "#{model_name.singular}_ancestors", association_foreign_key: "ancestor_id"
        has_and_belongs_to_many :descendants, class_name: model_name.to_s, join_table: "#{model_name.singular}_ancestors", foreign_key: "ancestor_id"
        after_save :rebuild_ancestry

        define_method :ancestor_ids do
          parent_model = self.send parent
          @ancestor_ids ||= parent_model.nil? ? [self.id] : [parent_model.id] + parent_model.ancestor_ids
        end

        define_method :rebuild_ancestry do
          self.ancestors = self.class.where(id: ancestor_ids) if saved_change_to_attribute(foreign_key)
        end
      end
    end
  end
end
