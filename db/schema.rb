# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180514100906) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "description_en"
    t.string "label_lang"
    t.string "wikidata_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pages", force: :cascade do |t|
    t.string "title", null: false
    t.string "position_held_item", null: false
    t.string "parliamentary_term_item"
    t.string "reference_url", null: false
    t.boolean "require_parliamentary_group", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reconciliations", force: :cascade do |t|
    t.bigint "statement_id"
    t.string "item"
    t.string "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["statement_id"], name: "index_reconciliations_on_statement_id"
  end

  create_table "statements", force: :cascade do |t|
    t.string "transaction_id"
    t.string "person_item"
    t.string "person_revision"
    t.string "statement_uuid"
    t.string "parliamentary_group_item"
    t.string "electoral_district_item"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "person_name"
    t.string "parliamentary_group_name"
    t.string "electoral_district_name"
    t.string "fb_identifier"
    t.boolean "duplicate", default: false
    t.bigint "page_id"
    t.index ["page_id"], name: "index_statements_on_page_id"
  end

  create_table "verifications", force: :cascade do |t|
    t.bigint "statement_id", null: false
    t.boolean "status", default: false
    t.string "user", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "new_name"
    t.index ["statement_id"], name: "index_verifications_on_statement_id"
  end

  add_foreign_key "reconciliations", "statements"
  add_foreign_key "statements", "pages"
end
