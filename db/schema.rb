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

ActiveRecord::Schema.define(version: 20141106152253) do

  create_table "programmes", force: true do |t|
    t.integer  "screens"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "visualisations_id"
    t.integer  "timeslot_id"
  end

  add_index "programmes", ["visualisations_id"], name: "index_programmes_on_visualisations_id"

  create_table "timeslots", force: true do |t|
    t.integer  "weekday"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "programmes_id"
  end

  add_index "timeslots", ["programmes_id"], name: "index_timeslots_on_programmes_id"

  create_table "users", force: true do |t|
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "username"
    t.boolean  "isAdmin"
    t.boolean  "isApproved"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "visualisations", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "link"
    t.string   "name"
    t.string   "description"
    t.string   "notes"
    t.string   "author_info"
    t.integer  "content_type"
    t.integer  "user_id"
    t.boolean  "approved"
    t.string   "content"
  end

end
