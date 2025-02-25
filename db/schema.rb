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

ActiveRecord::Schema[8.0].define(version: 2025_02_22_131434) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "blog_posts", force: :cascade do |t|
    t.string "title", null: false
    t.string "author", null: false
    t.datetime "posted", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "content", null: false
    t.string "visibility"
    t.string "blog_type"
    t.string "checksum", limit: 512
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["author"], name: "index_blog_posts_on_author"
    t.index ["title"], name: "index_blog_posts_on_title"
  end

  create_table "columns", force: :cascade do |t|
    t.string "column_name", null: false
    t.string "section_name", null: false
    t.string "column_type"
    t.integer "column_order"
    t.text "content"
    t.jsonb "options"
    t.string "image"
    t.string "link"
    t.jsonb "formatting"
    t.string "width"
    t.text "checksum"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["column_name", "section_name"], name: "index_columns_on_column_name_and_section_name", unique: true
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "message", null: false
    t.string "phone"
    t.string "submit_information"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["name", "email", "phone", "message"], name: "index_contacts_on_name_email_phone_and_message"
  end

  create_table "footer_items", force: :cascade do |t|
    t.string "label"
    t.text "icon"
    t.string "options"
    t.string "link"
    t.string "access"
    t.integer "footer_order"
    t.integer "parent_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "image_files", force: :cascade do |t|
    t.string "name", null: false
    t.string "caption"
    t.string "description"
    t.string "mime_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "group"
    t.integer "slide_order"
    t.string "checksum", limit: 512
    t.index ["name"], name: "index_image_files_on_name", unique: true
  end

  create_table "menu_items", force: :cascade do |t|
    t.string "menu_type"
    t.string "label"
    t.text "icon"
    t.string "options"
    t.string "link"
    t.string "access"
    t.integer "menu_order"
    t.integer "parent_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "pages", force: :cascade do |t|
    t.string "name", null: false
    t.string "section", null: false
    t.string "title"
    t.string "access"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "post_comments", force: :cascade do |t|
    t.bigint "blog_post_id"
    t.string "title", null: false
    t.string "author", null: false
    t.datetime "posted", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "content", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "checksum", limit: 512
    t.index ["author"], name: "index_post_comments_on_author"
    t.index ["blog_post_id"], name: "index_post_comments_on_blog_post_id"
    t.index ["title"], name: "index_post_comments_on_title"
  end

  create_table "sections", force: :cascade do |t|
    t.string "content_type", null: false
    t.string "section_name", null: false
    t.integer "section_order"
    t.string "image"
    t.string "link"
    t.text "description"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "checksum", limit: 512
    t.string "row_style"
    t.string "div_ratio"
    t.jsonb "image_attributes", default: {}, null: false
    t.jsonb "text_attributes", default: {}, null: false
    t.jsonb "formatting", default: {}, null: false
    t.index ["section_name"], name: "index_sections_on_section_name", unique: true
  end

  create_table "site_setups", force: :cascade do |t|
    t.string "configuration_name", null: false
    t.string "site_name", null: false
    t.string "site_domain", null: false
    t.string "site_host", null: false
    t.string "site_url", null: false
    t.string "header_background", default: "#0d6efd"
    t.string "header_text_color", default: "#f8f9fa"
    t.string "footer_background", default: "#0d6efd"
    t.string "footer_text_color", default: "#f8f9fa"
    t.string "container_background", default: "#f8f9fa"
    t.string "container_text_color", default: "#000000"
    t.string "page_background_image", default: "none"
    t.string "facebook_url"
    t.string "twitter_url"
    t.string "instagram_url"
    t.string "linkedin_url"
    t.string "github_url"
    t.string "owner_name"
    t.string "copyright"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "default_setup", default: false
    t.string "guest_user_name", default: "guest"
    t.string "special_user_name"
    t.string "smtp_server"
    t.string "smtp_port"
    t.string "smtp_user"
    t.string "smtp_password"
    t.string "smtp_domain"
    t.string "smtp_authentication"
    t.string "contact_email_from"
    t.string "contact_email_to"
    t.string "contact_email_subject"
    t.string "captcha_site_key"
    t.string "captcha_secret_key"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "roles"
    t.boolean "approved", default: false
    t.string "access"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
