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

ActiveRecord::Schema[7.0].define(version: 2023_01_29_215032) do
  create_table "documents", force: :cascade do |t|
    t.integer "folder_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["folder_id"], name: "index_documents_on_folder_id"
  end

  create_table "folders", force: :cascade do |t|
    t.integer "parent_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_folders_on_parent_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
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

  add_foreign_key "standard_procedure_action_links", "standard_procedure_actions", column: "action_id"
end
