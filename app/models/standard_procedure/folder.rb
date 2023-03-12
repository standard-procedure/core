module StandardProcedure
  class Folder < ApplicationRecord
    has_name
    has_reference
    has_fields
    has_ancestry cache_depth: true
    belongs_to :account, class_name: "StandardProcedure::Account"
    has_many :items,
             -> { order :position },
             class_name: "StandardProcedure::FolderItem",
             dependent: :destroy
    enum folder_status: { active: 0, deleted: -1000 }

    def organisation
      Organisation.where(id: ancestor_ids).first
    end

    def owner
      Contact.where(id: ancestor_ids).first
    end

    command :add_item do |type:, owner:, performed_by:, **params|
      build_item(type).tap do |item|
        item.update! params.merge(folder: folder, group: group, owner: owner)
        item.status.item_added(item: item, performed_by: user)
      end
    end

    protected

    def build_item(type, template: nil)
      item = items.build(type: type)
      item =
        item.with_fields_from(template.field_definition) if template.present?
      return item
    end
  end
end
