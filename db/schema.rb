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

ActiveRecord::Schema.define(version: 20160311214907) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "algorithms", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "version",        default: 0
    t.integer  "status",         default: 0
    t.string   "status_message"
    t.string   "diva_id"
    t.integer  "next_id"
    t.string   "secure_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "zip_file"
  end

  add_index "algorithms", ["user_id"], name: "index_algorithms_on_user_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "fields", force: :cascade do |t|
    t.string   "type"
    t.string   "category"
    t.integer  "fieldable_id"
    t.string   "fieldable_type"
    t.json     "payload"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "fields", ["category"], name: "index_fields_on_category", using: :btree
  add_index "fields", ["fieldable_type", "fieldable_id"], name: "index_fields_on_fieldable_type_and_fieldable_id", using: :btree
  add_index "fields", ["type"], name: "index_fields_on_type", using: :btree

  create_table "input_parameters", force: :cascade do |t|
    t.string   "input_type"
    t.integer  "position"
    t.string   "name"
    t.string   "description"
    t.integer  "algorithm_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "input_parameters", ["algorithm_id"], name: "index_input_parameters_on_algorithm_id", using: :btree

  create_table "output_parameters", force: :cascade do |t|
    t.string   "output_type"
    t.integer  "position"
    t.string   "name"
    t.string   "description"
    t.integer  "algorithm_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "output_parameters", ["algorithm_id"], name: "index_output_parameters_on_algorithm_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.boolean  "admin",                  default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
