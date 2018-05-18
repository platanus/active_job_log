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

ActiveRecord::Schema.define(version: 2018_05_11_184635) do
  create_table "active_job_log_jobs", force: :cascade do |t|
    t.string "job_id"
    t.text "params"
    t.string "status"
    t.string "job_class"
    t.string "error"
    t.text "stack_trace"
    t.datetime "queued_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer "queued_duration"
    t.integer "execution_duration"
    t.integer "total_duration"
    t.integer "executions"
    t.string "queue_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_active_job_log_jobs_on_job_id"
  end
end
