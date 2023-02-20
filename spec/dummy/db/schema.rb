# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_02_19_183643) do
  create_table "categories", force: :cascade do |t|
    t.integer "parent_id"
    t.string "name"
    t.string "plural"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "standard_procedure_accounts", force: :cascade do |t|
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "type", default: "", null: false
    t.text "field_data", limit: 16777216
    t.text "configuration", limit: 16777216
    t.date "active_from", null: false
    t.date "active_until", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "standard_procedure_action_links", force: :cascade do |t|
    t.integer "action_id"
    t.string "item_type"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_id"], name: "index_standard_procedure_action_links_on_action_id"
    t.index ["item_type", "item_id"], name: "index_standard_procedure_action_links_on_item"
  end

  create_table "standard_procedure_actions", force: :cascade do |t|
    t.integer "context_id"
    t.string "user_type"
    t.integer "user_id"
    t.string "target_type"
    t.integer "target_id"
    t.string "command", limit: 128, null: false
    t.integer "status", default: 0, null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["command"], name: "index_standard_procedure_actions_on_command"
    t.index ["context_id"], name: "index_standard_procedure_actions_on_context_id"
    t.index ["target_type", "target_id"], name: "index_standard_procedure_actions_on_target"
    t.index ["user_type", "user_id"], name: "index_standard_procedure_actions_on_user"
  end

  create_table "standard_procedure_alerts", force: :cascade do |t|
    t.string "item_type"
    t.integer "item_id"
    t.string "type", default: "", null: false
    t.datetime "due_at", null: false
    t.datetime "triggered_at"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_at"], name: "index_standard_procedure_alerts_on_due_at"
    t.index ["item_type", "item_id"], name: "index_standard_procedure_alerts_on_item"
  end

  create_table "standard_procedure_alerts_contacts", id: false, force: :cascade do |t|
    t.integer "standard_procedure_alert_id", null: false
    t.integer "standard_procedure_contact_id", null: false
  end

  create_table "standard_procedure_contacts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "role_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "type", default: "", null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_standard_procedure_contacts_on_group_id"
    t.index ["role_id"], name: "index_standard_procedure_contacts_on_role_id"
    t.index ["user_id"], name: "index_standard_procedure_contacts_on_user_id"
  end

  create_table "standard_procedure_field_definitions", force: :cascade do |t|
    t.string "definable_type"
    t.integer "definable_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.integer "position", default: 1, null: false
    t.string "type", limit: 128, null: false
    t.text "default_value"
    t.text "calculated_value"
    t.text "options"
    t.text "field_data", limit: 16777216
    t.boolean "mandatory", default: false, null: false
    t.integer "visible_to", default: 0, null: false
    t.integer "editable_by", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["definable_type", "definable_id"], name: "index_standard_procedure_field_definitions_on_definable"
  end

  create_table "standard_procedure_folder_items", force: :cascade do |t|
    t.integer "folder_id"
    t.string "contents_type"
    t.integer "contents_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "type", default: "", null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contents_type", "contents_id"], name: "index_standard_procedure_folder_items_on_contents"
    t.index ["folder_id"], name: "index_standard_procedure_folder_items_on_folder_id"
  end

  create_table "standard_procedure_folders", force: :cascade do |t|
    t.integer "account_id"
    t.integer "parent_id"
    t.integer "group_id"
    t.integer "contact_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "type", default: "", null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_standard_procedure_folders_on_account_id"
    t.index ["contact_id"], name: "index_standard_procedure_folders_on_contact_id"
    t.index ["group_id"], name: "index_standard_procedure_folders_on_group_id"
    t.index ["parent_id"], name: "index_standard_procedure_folders_on_parent_id"
  end

  create_table "standard_procedure_groups", force: :cascade do |t|
    t.integer "account_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "plural", default: "", null: false
    t.string "type", default: "", null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_standard_procedure_groups_on_account_id"
  end

  create_table "standard_procedure_permissions", force: :cascade do |t|
    t.string "type", default: "", null: false
    t.string "owner_type"
    t.integer "owner_id"
    t.string "restricted_type"
    t.integer "restricted_id"
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_standard_procedure_permissions_on_owner"
    t.index ["restricted_type", "restricted_id"], name: "index_standard_procedure_permissions_on_restricted"
  end

  create_table "standard_procedure_related_items", id: false, force: :cascade do |t|
    t.integer "workflow_item_id"
    t.integer "folder_item_id"
    t.index ["folder_item_id"], name: "index_standard_procedure_related_items_on_folder_item_id"
    t.index ["workflow_item_id"], name: "index_standard_procedure_related_items_on_workflow_item_id"
  end

  create_table "standard_procedure_roles", force: :cascade do |t|
    t.integer "account_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "plural", default: "", null: false
    t.integer "access_level", default: 0, null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_standard_procedure_roles_on_account_id"
  end

  create_table "standard_procedure_users", force: :cascade do |t|
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "type", default: "", null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "standard_procedure_workflow_item_templates", force: :cascade do |t|
    t.integer "account_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "plural", default: "", null: false
    t.string "type", default: "", null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_standard_procedure_workflow_item_templates_on_account_id"
  end

  create_table "standard_procedure_workflow_items", force: :cascade do |t|
    t.integer "template_id"
    t.integer "status_id"
    t.integer "group_id"
    t.integer "contact_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "type", default: "", null: false
    t.integer "position", default: 1, null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_standard_procedure_workflow_items_on_contact_id"
    t.index ["group_id"], name: "index_standard_procedure_workflow_items_on_group_id"
    t.index ["status_id"], name: "index_standard_procedure_workflow_items_on_status_id"
    t.index ["template_id"], name: "index_standard_procedure_workflow_items_on_template_id"
  end

  create_table "standard_procedure_workflow_statuses", force: :cascade do |t|
    t.integer "workflow_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "type", default: "", null: false
    t.integer "position", default: 1, null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workflow_id"], name: "index_standard_procedure_workflow_statuses_on_workflow_id"
  end

  create_table "standard_procedure_workflows", force: :cascade do |t|
    t.integer "account_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "type", default: "", null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_standard_procedure_workflows_on_account_id"
  end

  create_table "things", force: :cascade do |t|
    t.integer "category_id"
    t.string "name"
    t.text "field_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_things_on_category_id"
  end

  add_foreign_key "standard_procedure_action_links", "standard_procedure_actions", column: "action_id"
  add_foreign_key "standard_procedure_contacts", "standard_procedure_groups", column: "group_id"
  add_foreign_key "standard_procedure_contacts", "standard_procedure_roles", column: "role_id"
  add_foreign_key "standard_procedure_contacts", "standard_procedure_users", column: "user_id"
  add_foreign_key "standard_procedure_folder_items", "standard_procedure_folders", column: "folder_id"
  add_foreign_key "standard_procedure_folders", "standard_procedure_accounts", column: "account_id"
  add_foreign_key "standard_procedure_folders", "standard_procedure_contacts", column: "contact_id"
  add_foreign_key "standard_procedure_folders", "standard_procedure_folders", column: "parent_id"
  add_foreign_key "standard_procedure_folders", "standard_procedure_groups", column: "group_id"
  add_foreign_key "standard_procedure_groups", "standard_procedure_accounts", column: "account_id"
  add_foreign_key "standard_procedure_related_items", "standard_procedure_folder_items", column: "folder_item_id"
  add_foreign_key "standard_procedure_related_items", "standard_procedure_workflow_items", column: "workflow_item_id"
  add_foreign_key "standard_procedure_roles", "standard_procedure_accounts", column: "account_id"
  add_foreign_key "standard_procedure_workflow_item_templates", "standard_procedure_accounts", column: "account_id"
  add_foreign_key "standard_procedure_workflow_items", "standard_procedure_contacts", column: "contact_id"
  add_foreign_key "standard_procedure_workflow_items", "standard_procedure_groups", column: "group_id"
  add_foreign_key "standard_procedure_workflow_items", "standard_procedure_workflow_item_templates", column: "template_id"
  add_foreign_key "standard_procedure_workflow_items", "standard_procedure_workflow_statuses", column: "status_id"
  add_foreign_key "standard_procedure_workflow_statuses", "standard_procedure_workflows", column: "workflow_id"
  add_foreign_key "standard_procedure_workflows", "standard_procedure_accounts", column: "account_id"
end
