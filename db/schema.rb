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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120605102456) do

  create_table "email_aliases", :force => true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "email_aliases", ["email"], :name => "index_email_aliases_on_email"
  add_index "email_aliases", ["user_id"], :name => "index_email_aliases_on_user_id"

  create_table "fetched_mails", :force => true do |t|
    t.text     "from"
    t.text     "to"
    t.text     "cc"
    t.text     "bcc"
    t.text     "subject"
    t.text     "body"
    t.integer  "user_id"
    t.string   "message_id"
    t.string   "in_reply_to"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "fetched_mails", ["message_id"], :name => "index_fetched_mails_on_message_id", :unique => true
  add_index "fetched_mails", ["user_id"], :name => "index_fetched_mails_on_user_id"

  create_table "reminders", :force => true do |t|
    t.text     "other_recipients", :limit => 255
    t.integer  "fetched_mail_id"
    t.datetime "send_at"
    t.boolean  "delivered",                       :default => false, :null => false
    t.string   "snooze_token"
    t.integer  "snooze_count",                    :default => 0
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.boolean  "cleaned",                         :default => false
    t.string   "time"
  end

  add_index "reminders", ["fetched_mail_id"], :name => "index_reminders_on_fetched_mail_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "",   :null => false
    t.string   "encrypted_password",                   :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "timezone"
    t.string   "modify_token"
    t.boolean  "confirmation_email",                   :default => true
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["invited_by_id"], :name => "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
