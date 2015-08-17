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

ActiveRecord::Schema.define(version: 20150817025538) do

  create_table "cmip5s", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "datasets", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "type1",             limit: 255
    t.string   "type2",             limit: 255
    t.string   "category",          limit: 255
    t.string   "remark",            limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size",    limit: 4
    t.datetime "file_updated_at"
  end

  create_table "settings_datamodels", force: :cascade do |t|
    t.string   "name",       limit: 50
    t.string   "institute",  limit: 255
    t.string   "remark",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "stdname",    limit: 50
  end

  create_table "settings_datasetpaths", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "path",       limit: 255
    t.string   "remark",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "settings_ensembles", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "fullname",    limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "settings_experiments", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "fullname",    limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "settings_mips", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "fullname",    limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "settings_temporals", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "remark",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "settings_variables", force: :cascade do |t|
    t.string   "name",        limit: 10
    t.string   "fullname",    limit: 50
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "unit",        limit: 10
    t.integer  "c_rate",      limit: 4
    t.string   "c_unit",      limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",               limit: 255
    t.string   "role",                   limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
