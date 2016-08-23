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

ActiveRecord::Schema.define(version: 20160823180337) do

  create_table "bans", force: :cascade do |t|
    t.string   "reason",                     null: false
    t.datetime "expires_at"
    t.integer  "user_id",                    null: false
    t.integer  "creator_id",                 null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "deleted",    default: false, null: false
    t.index ["creator_id"], name: "index_bans_on_creator_id"
    t.index ["user_id"], name: "index_bans_on_user_id"
  end

  create_table "characters", force: :cascade do |t|
    t.string   "name",                           null: false
    t.string   "title"
    t.string   "description"
    t.integer  "user_id"
    t.integer  "creator_id",                     null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "deleted",        default: false, null: false
    t.integer  "posts_count",    default: 0,     null: false
    t.string   "avatar"
    t.string   "gallery_images"
    t.index ["creator_id"], name: "index_characters_on_creator_id"
    t.index ["name"], name: "index_characters_on_name"
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.integer  "posts_count",         default: 0,     null: false
    t.boolean  "deleted",             default: false, null: false
    t.integer  "author_id",                           null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "views_count",         default: 0,     null: false
    t.string   "title",                               null: false
    t.boolean  "locked",              default: false, null: false
    t.datetime "locked_on"
    t.integer  "locked_by_id"
    t.integer  "visible_posts_count", default: 0,     null: false
    t.index ["author_id"], name: "index_conversations_on_author_id"
    t.index ["locked_by_id"], name: "index_conversations_on_locked_by_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",                               null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                          null: false
    t.string   "scopes"
    t.string   "previous_refresh_token", default: "", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.text     "body",                            null: false
    t.integer  "author_id",                       null: false
    t.integer  "editor_id"
    t.integer  "character_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "deleted",         default: false, null: false
    t.integer  "conversation_id",                 null: false
    t.text     "formatted_body"
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["character_id"], name: "index_posts_on_character_id"
    t.index ["conversation_id"], name: "index_posts_on_postable_type_and_conversation_id"
    t.index ["editor_id"], name: "index_posts_on_editor_id"
    t.index ["title"], name: "index_posts_on_title"
  end

  create_table "reports", force: :cascade do |t|
    t.string   "reportable_type",                  null: false
    t.integer  "reportable_id",                    null: false
    t.string   "status",          default: "open", null: false
    t.text     "description"
    t.integer  "creator_id",                       null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["creator_id"], name: "index_reports_on_creator_id"
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable_type_and_reportable_id"
    t.index ["status"], name: "index_reports_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                    null: false
    t.string   "email_token"
    t.datetime "email_confirmed_at"
    t.string   "password_digest"
    t.string   "display_name"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "date_of_birth",                            null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "admin",                    default: false, null: false
    t.integer  "characters_count",         default: 0,     null: false
    t.integer  "created_characters_count", default: 0,     null: false
    t.integer  "posts_count",              default: 0,     null: false
    t.string   "avatar"
    t.boolean  "deleted",                  default: false, null: false
    t.boolean  "banned",                   default: false, null: false
    t.integer  "visible_posts_count",      default: 0,     null: false
    t.datetime "last_active_at"
    t.index ["display_name"], name: "index_users_on_display_name", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_token"], name: "index_users_on_email_token", unique: true
  end

end
