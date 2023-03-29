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

ActiveRecord::Schema[7.0].define(version: 2023_03_29_194159) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.integer "parent_id"
    t.string "name"
    t.string "plural"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "people", force: :cascade do |t|
    t.integer "category_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_people_on_category_id"
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

  create_table "standard_procedure_alert_contacts_links", id: false, force: :cascade do |t|
    t.integer "alert_id"
    t.integer "contact_id"
    t.index ["alert_id"], name: "index_standard_procedure_alert_contacts_links_on_alert_id"
    t.index ["contact_id"], name: "index_standard_procedure_alert_contacts_links_on_contact_id"
  end

  create_table "standard_procedure_alerts", force: :cascade do |t|
    t.string "item_type"
    t.integer "item_id"
    t.string "type", default: "", null: false
    t.datetime "due_at", null: false
    t.datetime "triggered_at"
    t.integer "status", default: 0, null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_at"], name: "index_standard_procedure_alerts_on_due_at"
    t.index ["item_type", "item_id"], name: "index_standard_procedure_alerts_on_item"
  end

  create_table "standard_procedure_alerts_folders", id: false, force: :cascade do |t|
    t.integer "standard_procedure_alert_id", null: false
    t.integer "standard_procedure_folder_id", null: false
  end

  create_table "standard_procedure_calendar_item_attendees", id: false, force: :cascade do |t|
    t.bigint "calendar_item_id"
    t.bigint "attendee_id"
    t.index ["attendee_id"], name: "attendee_calendar_items"
    t.index ["calendar_item_id"], name: "calendar_item_attendees"
  end

  create_table "standard_procedure_command_links", force: :cascade do |t|
    t.integer "command_id"
    t.string "item_type"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["command_id"], name: "index_standard_procedure_command_links_on_command_id"
    t.index ["item_type", "item_id"], name: "index_standard_procedure_command_links_on_item"
  end

  create_table "standard_procedure_commands", force: :cascade do |t|
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
    t.index ["command"], name: "index_standard_procedure_commands_on_command"
    t.index ["context_id"], name: "index_standard_procedure_commands_on_context_id"
    t.index ["target_type", "target_id"], name: "index_standard_procedure_commands_on_target"
    t.index ["user_type", "user_id"], name: "index_standard_procedure_commands_on_user"
  end

  create_table "standard_procedure_document_templates", force: :cascade do |t|
    t.integer "account_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "plural", default: "", null: false
    t.string "type", default: "", null: false
    t.string "item_type", default: "StandardProcedure::Document", null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_standard_procedure_document_templates_on_account_id"
  end

  create_table "standard_procedure_field_definitions", force: :cascade do |t|
    t.string "definable_type"
    t.integer "definable_id"
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.integer "position", default: 1, null: false
    t.string "type", limit: 128, null: false
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
    t.integer "owner_id"
    t.integer "position", default: 1, null: false
    t.integer "item_status", default: 0, null: false
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "type", default: "", null: false
    t.text "field_data", limit: 16777216
    t.integer "template_id"
    t.integer "status_id"
    t.integer "assigned_to_id"
    t.date "date"
    t.time "starts_at"
    t.time "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_standard_procedure_folder_items_on_assigned_to_id"
    t.index ["folder_id"], name: "index_standard_procedure_folder_items_on_folder_id"
    t.index ["owner_id", "date"], name: "index_standard_procedure_folder_items_on_owner_id_and_date"
    t.index ["owner_id"], name: "index_standard_procedure_folder_items_on_owner_id"
    t.index ["status_id"], name: "index_standard_procedure_folder_items_on_status_id"
    t.index ["template_id"], name: "index_standard_procedure_folder_items_on_template_id"
  end

  create_table "standard_procedure_folders", force: :cascade do |t|
    t.string "reference", default: "", null: false
    t.string "name", default: "", null: false
    t.string "type", default: "", null: false
    t.string "ancestry", default: "", null: false
    t.integer "ancestry_depth", default: 0, null: false
    t.integer "account_id"
    t.text "field_data", limit: 16777216
    t.integer "user_id"
    t.integer "role_id"
    t.string "access_code", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_code"], name: "index_standard_procedure_folders_on_access_code"
    t.index ["account_id"], name: "index_standard_procedure_folders_on_account_id"
    t.index ["ancestry"], name: "index_standard_procedure_folders_on_ancestry"
    t.index ["role_id"], name: "index_standard_procedure_folders_on_role_id"
    t.index ["user_id"], name: "index_standard_procedure_folders_on_user_id"
  end

  create_table "standard_procedure_message_links", force: :cascade do |t|
    t.integer "message_id"
    t.string "item_type"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_standard_procedure_message_links_on_item"
    t.index ["message_id"], name: "index_standard_procedure_message_links_on_message_id"
  end

  create_table "standard_procedure_message_recipients", force: :cascade do |t|
    t.integer "message_id"
    t.integer "recipient_id"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_standard_procedure_message_recipients_on_message_id"
    t.index ["recipient_id"], name: "index_standard_procedure_message_recipients_on_recipient_id"
  end

  create_table "standard_procedure_messages", force: :cascade do |t|
    t.integer "sender_id"
    t.string "subject", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sender_id"], name: "index_standard_procedure_messages_on_sender_id"
  end

  create_table "standard_procedure_notification_links", force: :cascade do |t|
    t.integer "notification_id"
    t.string "item_type"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_standard_procedure_notification_links_on_item"
    t.index ["notification_id"], name: "index_standard_procedure_notification_links_on_notification_id"
  end

  create_table "standard_procedure_notifications", force: :cascade do |t|
    t.integer "contact_id"
    t.string "type", default: "", null: false
    t.datetime "sent_at"
    t.datetime "acknowledged_at"
    t.integer "notification_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_standard_procedure_notifications_on_contact_id"
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
    t.integer "document_id"
    t.integer "folder_item_id"
    t.index ["document_id"], name: "index_standard_procedure_related_items_on_document_id"
    t.index ["folder_item_id"], name: "index_standard_procedure_related_items_on_folder_item_id"
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

  create_table "standard_procedure_workflow_actions", force: :cascade do |t|
    t.integer "performed_by_id"
    t.integer "document_id"
    t.string "type", default: "", null: false
    t.text "field_data", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_standard_procedure_workflow_actions_on_document_id"
    t.index ["performed_by_id"], name: "index_standard_procedure_workflow_actions_on_performed_by_id"
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
    t.integer "person_id"
    t.string "name"
    t.string "reference"
    t.text "field_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_things_on_category_id"
    t.index ["person_id"], name: "index_things_on_person_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "standard_procedure_alert_contacts_links", "standard_procedure_alerts", column: "alert_id"
  add_foreign_key "standard_procedure_alert_contacts_links", "standard_procedure_folders", column: "contact_id"
  add_foreign_key "standard_procedure_command_links", "standard_procedure_commands", column: "command_id"
  add_foreign_key "standard_procedure_document_templates", "standard_procedure_accounts", column: "account_id"
  add_foreign_key "standard_procedure_folder_items", "standard_procedure_document_templates", column: "template_id"
  add_foreign_key "standard_procedure_folder_items", "standard_procedure_folders", column: "assigned_to_id"
  add_foreign_key "standard_procedure_folder_items", "standard_procedure_folders", column: "folder_id"
  add_foreign_key "standard_procedure_folder_items", "standard_procedure_folders", column: "owner_id"
  add_foreign_key "standard_procedure_folder_items", "standard_procedure_workflow_statuses", column: "status_id"
  add_foreign_key "standard_procedure_folders", "standard_procedure_accounts", column: "account_id"
  add_foreign_key "standard_procedure_folders", "standard_procedure_roles", column: "role_id"
  add_foreign_key "standard_procedure_folders", "standard_procedure_users", column: "user_id"
  add_foreign_key "standard_procedure_message_links", "standard_procedure_messages", column: "message_id"
  add_foreign_key "standard_procedure_message_recipients", "standard_procedure_folders", column: "recipient_id"
  add_foreign_key "standard_procedure_message_recipients", "standard_procedure_messages", column: "message_id"
  add_foreign_key "standard_procedure_messages", "standard_procedure_folders", column: "sender_id"
  add_foreign_key "standard_procedure_notification_links", "standard_procedure_notifications", column: "notification_id"
  add_foreign_key "standard_procedure_notifications", "standard_procedure_folders", column: "contact_id"
  add_foreign_key "standard_procedure_related_items", "standard_procedure_folder_items", column: "document_id"
  add_foreign_key "standard_procedure_related_items", "standard_procedure_folder_items", column: "folder_item_id"
  add_foreign_key "standard_procedure_roles", "standard_procedure_accounts", column: "account_id"
  add_foreign_key "standard_procedure_workflow_actions", "standard_procedure_folder_items", column: "document_id"
  add_foreign_key "standard_procedure_workflow_actions", "standard_procedure_users", column: "performed_by_id"
  add_foreign_key "standard_procedure_workflow_statuses", "standard_procedure_workflows", column: "workflow_id"
  add_foreign_key "standard_procedure_workflows", "standard_procedure_accounts", column: "account_id"
end
