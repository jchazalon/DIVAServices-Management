# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160303104708) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "algorithm_infos", force: :cascade do |t|
    t.integer  "algorithm_id"
    t.json     "payload"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "algorithm_infos", ["algorithm_id"], name: "index_algorithm_infos_on_algorithm_id", using: :btree

  create_table "algorithms", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "namespace"
    t.text     "description"
    t.string   "output"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "algorithms", ["user_id"], name: "index_algorithms_on_user_id", using: :btree

  create_table "fields", force: :cascade do |t|
    t.string   "type"
    t.integer  "fieldable_id"
    t.string   "fieldable_type"
    t.json     "payload"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "fields", ["fieldable_type", "fieldable_id"], name: "index_fields_on_fieldable_type_and_fieldable_id", using: :btree
  add_index "fields", ["type"], name: "index_fields_on_type", using: :btree

  create_table "input_parameters", force: :cascade do |t|
    t.string   "input_type"
    t.integer  "algorithm_id"
    t.integer  "field_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "input_parameters", ["algorithm_id"], name: "index_input_parameters_on_algorithm_id", using: :btree
  add_index "input_parameters", ["field_id"], name: "index_input_parameters_on_field_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
