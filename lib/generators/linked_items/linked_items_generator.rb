class LinkedItemsGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  source_root File.expand_path("templates", __dir__)
  check_class_collision suffix: "Link"

  def create_link_model
    template "model.rb.erb", "app/models/#{link_file_path}"
    migration_template "migration.rb.erb", "db/migrate/create_#{link_table_name}.rb"
  end

  def add_has_links_declaration
    insert_into_file file_path, "has_linked :#{source_plural}", after: "< ApplicationRecord"
  end

  class << self
    def next_migration_number(dirname)
      next_migration_number = current_migration_number(dirname) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end
  end

  protected

  def link_class_name
    "#{class_name}Link"
  end

  def link_file_path
    "#{file_path}_link"
  end

  def link_table_name
    link_class_name.gsub("::", "").tableize
  end

  def source_name
    "item"
  end

  def source_plural
    source_name.pluralize
  end
end
