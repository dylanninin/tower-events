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

ActiveRecord::Schema.define(version: 20170609061100) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accesses", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "team_id"
    t.string "role", limit: 50, null: false
    t.string "accessable_type"
    t.bigint "accessable_id"
    t.bigint "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accessable_type", "accessable_id"], name: "index_accesses_on_accessable_type_and_accessable_id"
    t.index ["creator_id"], name: "index_accesses_on_creator_id"
    t.index ["deleted_at"], name: "index_accesses_on_deleted_at"
    t.index ["team_id"], name: "index_accesses_on_team_id"
    t.index ["user_id"], name: "index_accesses_on_user_id"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.date "start_date"
    t.date "end_date"
    t.integer "status", default: 0
    t.string "calendarable_type"
    t.bigint "calendarable_id"
    t.bigint "team_id"
    t.bigint "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendarable_type", "calendarable_id"], name: "index_calendar_events_on_calendarable_type_and_calendarable_id"
    t.index ["creator_id"], name: "index_calendar_events_on_creator_id"
    t.index ["deleted_at"], name: "index_calendar_events_on_deleted_at"
    t.index ["team_id"], name: "index_calendar_events_on_team_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "color", null: false
    t.integer "status", default: 0
    t.bigint "team_id"
    t.bigint "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_calendars_on_creator_id"
    t.index ["deleted_at"], name: "index_calendars_on_deleted_at"
    t.index ["team_id"], name: "index_calendars_on_team_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "text", null: false
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.bigint "team_id"
    t.bigint "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "replied_to_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["creator_id"], name: "index_comments_on_creator_id"
    t.index ["deleted_at"], name: "index_comments_on_deleted_at"
    t.index ["replied_to_id"], name: "index_comments_on_replied_to_id"
    t.index ["team_id"], name: "index_comments_on_team_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "verb", limit: 20, null: false
    t.jsonb "actor", null: false
    t.jsonb "object", null: false
    t.jsonb "target"
    t.jsonb "generator"
    t.jsonb "provider"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published", null: false
    t.jsonb "parameters"
    t.index "((generator -> 'id'::text)), ((generator -> 'type'::text))", name: "index_events_on_generator", using: :gin
    t.index "((object -> 'id'::text)), ((object -> 'type'::text))", name: "index_events_on_object", using: :gin
    t.index ["deleted_at"], name: "index_events_on_deleted_at"
    t.index ["published"], name: "index_events_on_published"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "description"
    t.integer "status", default: 0
    t.bigint "team_id", null: false
    t.bigint "creator_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_projects_on_creator_id"
    t.index ["deleted_at"], name: "index_projects_on_deleted_at"
    t.index ["team_id"], name: "index_projects_on_team_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "content", null: false
    t.integer "status", default: 0
    t.bigint "team_id"
    t.bigint "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_reports_on_creator_id"
    t.index ["deleted_at"], name: "index_reports_on_deleted_at"
    t.index ["team_id"], name: "index_reports_on_team_id"
  end

  create_table "team_members", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "member_id", null: false
    t.bigint "creator_id"
    t.string "role", limit: 50, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_team_members_on_creator_id"
    t.index ["deleted_at"], name: "index_team_members_on_deleted_at"
    t.index ["member_id"], name: "index_team_members_on_member_id"
    t.index ["team_id"], name: "index_team_members_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "description"
    t.integer "status", default: 0
    t.bigint "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_teams_on_creator_id"
    t.index ["deleted_at"], name: "index_teams_on_deleted_at"
  end

  create_table "todo_lists", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.integer "status", default: 0
    t.bigint "project_id"
    t.bigint "team_id"
    t.bigint "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_todo_lists_on_creator_id"
    t.index ["deleted_at"], name: "index_todo_lists_on_deleted_at"
    t.index ["project_id"], name: "index_todo_lists_on_project_id"
    t.index ["team_id"], name: "index_todo_lists_on_team_id"
  end

  create_table "todos", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "content", null: false
    t.integer "status", default: 0
    t.date "due_to"
    t.bigint "assignee_id"
    t.bigint "todo_list_id"
    t.bigint "project_id"
    t.bigint "team_id"
    t.bigint "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_todos_on_assignee_id"
    t.index ["creator_id"], name: "index_todos_on_creator_id"
    t.index ["deleted_at"], name: "index_todos_on_deleted_at"
    t.index ["project_id"], name: "index_todos_on_project_id"
    t.index ["team_id"], name: "index_todos_on_team_id"
    t.index ["todo_list_id"], name: "index_todos_on_todo_list_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar"
    t.string "name", limit: 50, null: false
    t.integer "status", default: 0
    t.string "email", null: false
    t.string "password_digest"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "accesses", "teams"
  add_foreign_key "accesses", "users"
  add_foreign_key "accesses", "users", column: "creator_id"
  add_foreign_key "calendar_events", "teams"
  add_foreign_key "calendar_events", "users", column: "creator_id"
  add_foreign_key "calendars", "teams"
  add_foreign_key "calendars", "users", column: "creator_id"
  add_foreign_key "comments", "teams"
  add_foreign_key "comments", "users", column: "creator_id"
  add_foreign_key "projects", "teams"
  add_foreign_key "projects", "users", column: "creator_id"
  add_foreign_key "reports", "teams"
  add_foreign_key "reports", "users", column: "creator_id"
  add_foreign_key "team_members", "teams"
  add_foreign_key "team_members", "users", column: "creator_id"
  add_foreign_key "team_members", "users", column: "member_id"
  add_foreign_key "teams", "users", column: "creator_id"
  add_foreign_key "todo_lists", "projects"
  add_foreign_key "todo_lists", "teams"
  add_foreign_key "todo_lists", "users", column: "creator_id"
  add_foreign_key "todos", "projects"
  add_foreign_key "todos", "teams"
  add_foreign_key "todos", "todo_lists"
  add_foreign_key "todos", "users", column: "assignee_id"
  add_foreign_key "todos", "users", column: "creator_id"
end
