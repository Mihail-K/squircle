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

ActiveRecord::Schema.define(version: 20161119211638) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bans", force: :cascade do |t|
    t.string   "reason",                        null: false
    t.datetime "expires_at"
    t.integer  "user_id",                       null: false
    t.integer  "creator_id",                    null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "deleted",       default: false, null: false
    t.integer  "deleted_by_id"
    t.datetime "deleted_at"
    t.index ["creator_id"], name: "index_bans_on_creator_id", using: :btree
    t.index ["deleted_by_id"], name: "index_bans_on_deleted_by_id", using: :btree
    t.index ["user_id"], name: "index_bans_on_user_id", using: :btree
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
    t.integer  "deleted_by_id"
    t.datetime "deleted_at"
    t.string   "display_name"
    t.index ["creator_id"], name: "index_characters_on_creator_id", using: :btree
    t.index ["deleted_by_id"], name: "index_characters_on_deleted_by_id", using: :btree
    t.index ["name"], name: "index_characters_on_name", using: :btree
    t.index ["user_id"], name: "index_characters_on_user_id", using: :btree
  end

  create_table "configs", force: :cascade do |t|
    t.string   "key",                     null: false
    t.jsonb    "value",      default: {}, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["key"], name: "index_configs_on_key", unique: true, using: :btree
  end

  create_table "conversations", force: :cascade do |t|
    t.integer  "posts_count",    default: 0,     null: false
    t.boolean  "deleted",        default: false, null: false
    t.integer  "author_id",                      null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "views_count",    default: 0,     null: false
    t.string   "title",                          null: false
    t.boolean  "locked",         default: false, null: false
    t.datetime "locked_at"
    t.integer  "locked_by_id"
    t.datetime "last_active_at"
    t.integer  "section_id",                     null: false
    t.integer  "deleted_by_id"
    t.datetime "deleted_at"
    t.integer  "first_post_id"
    t.integer  "last_post_id"
    t.index ["author_id"], name: "index_conversations_on_author_id", using: :btree
    t.index ["deleted_by_id"], name: "index_conversations_on_deleted_by_id", using: :btree
    t.index ["first_post_id"], name: "index_conversations_on_first_post_id", using: :btree
    t.index ["last_post_id"], name: "index_conversations_on_last_post_id", using: :btree
    t.index ["locked_by_id"], name: "index_conversations_on_locked_by_id", using: :btree
    t.index ["section_id"], name: "index_conversations_on_section_id", using: :btree
  end

  create_table "friendships", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "friend_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
    t.index ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_friendships_on_user_id", using: :btree
  end

  create_table "indices", force: :cascade do |t|
    t.string   "indexable_type",             null: false
    t.integer  "indexable_id",               null: false
    t.string   "primary",                    null: false, array: true
    t.text     "secondary",                               array: true
    t.text     "tertiary",                                array: true
    t.integer  "version",        default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["indexable_type", "indexable_id"], name: "index_indices_on_indexable_type_and_indexable_id", unique: true, using: :btree
    t.index ["primary"], name: "index_indices_on_primary", using: :btree
    t.index ["secondary"], name: "index_indices_on_secondary", using: :btree
    t.index ["tertiary"], name: "index_indices_on_tertiary", using: :btree
  end

  create_table "likes", force: :cascade do |t|
    t.string   "likeable_type", null: false
    t.integer  "likeable_id",   null: false
    t.integer  "user_id",       null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "display_name",  null: false
    t.index ["likeable_id", "likeable_type", "user_id"], name: "index_likes_on_likeable_id_and_likeable_type_and_user_id", unique: true, using: :btree
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable_type_and_likeable_id", using: :btree
    t.index ["user_id"], name: "index_likes_on_user_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",                         null: false
    t.string   "targetable_type",                 null: false
    t.integer  "targetable_id",                   null: false
    t.string   "title",                           null: false
    t.boolean  "read",            default: false, null: false
    t.boolean  "dismissed",       default: false, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "sourceable_type"
    t.integer  "sourceable_id"
    t.index ["dismissed"], name: "index_notifications_on_dismissed", using: :btree
    t.index ["read", "dismissed"], name: "index_notifications_on_read_and_dismissed", using: :btree
    t.index ["read"], name: "index_notifications_on_read", using: :btree
    t.index ["sourceable_type", "sourceable_id"], name: "index_notifications_on_sourceable_type_and_sourceable_id", using: :btree
    t.index ["targetable_type", "targetable_id"], name: "index_notifications_on_targetable_type_and_targetable_id", using: :btree
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
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
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree
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
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree
  end

  create_table "permissible_implied_permissions", force: :cascade do |t|
    t.integer "permission_id", null: false
    t.integer "implied_by_id", null: false
    t.index ["implied_by_id"], name: "index_permissible_implied_permissions_on_implied_by_id", using: :btree
    t.index ["permission_id", "implied_by_id"], name: "permissible_index_on_permission_and_implied_by", unique: true, using: :btree
    t.index ["permission_id"], name: "index_permissible_implied_permissions_on_permission_id", using: :btree
  end

  create_table "permissible_model_permissions", force: :cascade do |t|
    t.integer  "permission_id",                      null: false
    t.string   "permissible_type",                   null: false
    t.integer  "permissible_id",                     null: false
    t.string   "value",            default: "allow", null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["permissible_type", "permissible_id"], name: "permissible_index_on_polymorphic_permissible", using: :btree
    t.index ["permission_id", "permissible_id", "permissible_type"], name: "permissible_index_on_id_and_polymorphic_permissible", unique: true, using: :btree
    t.index ["permission_id"], name: "index_permissible_model_permissions_on_permission_id", using: :btree
    t.index ["value"], name: "index_permissible_model_permissions_on_value", using: :btree
  end

  create_table "permissible_permissions", force: :cascade do |t|
    t.string   "name",                     null: false
    t.text     "description", default: "", null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["name"], name: "index_permissible_permissions_on_name", unique: true, using: :btree
  end

  create_table "permissions", force: :cascade do |t|
    t.string   "name",                          null: false
    t.text     "description"
    t.boolean  "deleted",       default: false, null: false
    t.integer  "deleted_by_id"
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "implied_by_id"
    t.index ["deleted"], name: "index_permissions_on_deleted", using: :btree
    t.index ["deleted_by_id"], name: "index_permissions_on_deleted_by_id", using: :btree
    t.index ["implied_by_id"], name: "index_permissions_on_implied_by_id", using: :btree
    t.index ["name"], name: "index_permissions_on_name", unique: true, using: :btree
  end

  create_table "posts", force: :cascade do |t|
    t.text     "body",                            null: false
    t.integer  "author_id",                       null: false
    t.integer  "editor_id"
    t.integer  "character_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "deleted",         default: false, null: false
    t.integer  "conversation_id",                 null: false
    t.text     "formatted_body"
    t.integer  "deleted_by_id"
    t.datetime "deleted_at"
    t.integer  "likes_count",     default: 0,     null: false
    t.string   "display_name",                    null: false
    t.index ["author_id"], name: "index_posts_on_author_id", using: :btree
    t.index ["character_id"], name: "index_posts_on_character_id", using: :btree
    t.index ["conversation_id"], name: "index_posts_on_conversation_id", using: :btree
    t.index ["deleted_by_id"], name: "index_posts_on_deleted_by_id", using: :btree
    t.index ["editor_id"], name: "index_posts_on_editor_id", using: :btree
  end

  create_table "reports", force: :cascade do |t|
    t.string   "reportable_type",                  null: false
    t.integer  "reportable_id",                    null: false
    t.string   "status",          default: "open", null: false
    t.text     "description"
    t.integer  "creator_id",                       null: false
    t.boolean  "deleted",         default: false,  null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.datetime "closed_at"
    t.integer  "closed_by_id"
    t.integer  "deleted_by_id"
    t.datetime "deleted_at"
    t.index ["closed_by_id"], name: "index_reports_on_closed_by_id", using: :btree
    t.index ["creator_id"], name: "index_reports_on_creator_id", using: :btree
    t.index ["deleted"], name: "index_reports_on_deleted", using: :btree
    t.index ["deleted_by_id"], name: "index_reports_on_deleted_by_id", using: :btree
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable_type_and_reportable_id", using: :btree
    t.index ["status"], name: "index_reports_on_status", using: :btree
  end

  create_table "role_permissions", force: :cascade do |t|
    t.integer  "role_id",                         null: false
    t.integer  "permission_id",                   null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "value",         default: "allow", null: false
    t.boolean  "deleted",       default: false,   null: false
    t.integer  "deleted_by_id"
    t.datetime "deleted_at"
    t.index ["deleted_by_id"], name: "index_role_permissions_on_deleted_by_id", using: :btree
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id", using: :btree
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true, using: :btree
    t.index ["role_id"], name: "index_role_permissions_on_role_id", using: :btree
    t.index ["value"], name: "index_role_permissions_on_value", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",                          null: false
    t.text     "description"
    t.boolean  "deleted",       default: false, null: false
    t.integer  "deleted_by_id"
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["deleted"], name: "index_roles_on_deleted", using: :btree
    t.index ["deleted_by_id"], name: "index_roles_on_deleted_by_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", unique: true, using: :btree
  end

  create_table "roles_users", force: :cascade do |t|
    t.integer  "role_id",    null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", unique: true, using: :btree
    t.index ["role_id"], name: "index_roles_users_on_role_id", using: :btree
    t.index ["user_id"], name: "index_roles_users_on_user_id", using: :btree
  end

  create_table "sections", force: :cascade do |t|
    t.string   "title",                               null: false
    t.text     "description"
    t.string   "logo"
    t.integer  "conversations_count", default: 0,     null: false
    t.boolean  "deleted",             default: false, null: false
    t.integer  "creator_id",                          null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "posts_count",         default: 0,     null: false
    t.integer  "deleted_by_id"
    t.datetime "deleted_at"
    t.integer  "parent_id"
    t.index ["creator_id"], name: "index_sections_on_creator_id", using: :btree
    t.index ["deleted_by_id"], name: "index_sections_on_deleted_by_id", using: :btree
    t.index ["parent_id"], name: "index_sections_on_parent_id", using: :btree
    t.index ["title"], name: "index_sections_on_title", using: :btree
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id",         null: false
    t.integer  "conversation_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["conversation_id"], name: "index_subscriptions_on_conversation_id", using: :btree
    t.index ["user_id", "conversation_id"], name: "index_subscriptions_on_user_id_and_conversation_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_subscriptions_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                       null: false
    t.string   "email_token"
    t.datetime "email_confirmed_at"
    t.string   "password_digest"
    t.string   "display_name"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "date_of_birth",                               null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "characters_count",         default: 0,        null: false
    t.integer  "created_characters_count", default: 0,        null: false
    t.integer  "posts_count",              default: 0,        null: false
    t.string   "avatar"
    t.boolean  "deleted",                  default: false,    null: false
    t.boolean  "banned",                   default: false,    null: false
    t.datetime "last_active_at"
    t.integer  "deleted_by_id"
    t.datetime "deleted_at"
    t.string   "bucket",                   default: "active", null: false
    t.datetime "last_email_at"
    t.index ["deleted_by_id"], name: "index_users_on_deleted_by_id", using: :btree
    t.index ["display_name"], name: "index_users_on_display_name", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["email_token"], name: "index_users_on_email_token", unique: true, using: :btree
  end

  add_foreign_key "bans", "users"
  add_foreign_key "bans", "users", column: "creator_id"
  add_foreign_key "bans", "users", column: "deleted_by_id"
  add_foreign_key "characters", "users"
  add_foreign_key "characters", "users", column: "creator_id"
  add_foreign_key "characters", "users", column: "deleted_by_id"
  add_foreign_key "conversations", "posts", column: "first_post_id", on_delete: :nullify
  add_foreign_key "conversations", "posts", column: "last_post_id", on_delete: :nullify
  add_foreign_key "conversations", "sections"
  add_foreign_key "conversations", "users", column: "author_id"
  add_foreign_key "conversations", "users", column: "deleted_by_id"
  add_foreign_key "conversations", "users", column: "locked_by_id"
  add_foreign_key "friendships", "users"
  add_foreign_key "friendships", "users", column: "friend_id"
  add_foreign_key "likes", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "permissible_implied_permissions", "permissible_permissions", column: "implied_by_id"
  add_foreign_key "permissible_implied_permissions", "permissible_permissions", column: "permission_id"
  add_foreign_key "permissible_model_permissions", "permissible_permissions", column: "permission_id"
  add_foreign_key "permissions", "permissions", column: "implied_by_id"
  add_foreign_key "permissions", "users", column: "deleted_by_id"
  add_foreign_key "posts", "characters"
  add_foreign_key "posts", "conversations"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "posts", "users", column: "deleted_by_id"
  add_foreign_key "posts", "users", column: "editor_id"
  add_foreign_key "reports", "users", column: "closed_by_id"
  add_foreign_key "reports", "users", column: "creator_id"
  add_foreign_key "reports", "users", column: "deleted_by_id"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "role_permissions", "users", column: "deleted_by_id"
  add_foreign_key "roles", "users", column: "deleted_by_id"
  add_foreign_key "roles_users", "roles"
  add_foreign_key "roles_users", "users"
  add_foreign_key "sections", "sections", column: "parent_id"
  add_foreign_key "sections", "users", column: "creator_id"
  add_foreign_key "sections", "users", column: "deleted_by_id"
  add_foreign_key "subscriptions", "conversations"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "users", "users", column: "deleted_by_id"
end
