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

ActiveRecord::Schema.define(version: 20200115204159) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.string "description"
  end

  create_table "association_enrollments", force: :cascade do |t|
    t.integer  "record_enrollment_id"
    t.integer  "disciplines_enrollment_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["disciplines_enrollment_id"], name: "index_association_enrollments_on_disciplines_enrollment_id", using: :btree
    t.index ["record_enrollment_id"], name: "index_association_enrollments_on_record_enrollment_id", using: :btree
  end

  create_table "coordinators", force: :cascade do |t|
    t.string   "name"
    t.string   "username"
    t.integer  "course_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_coordinators_on_course_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_coordinators_on_user_id", unique: true, using: :btree
  end

  create_table "course_class_offers", force: :cascade do |t|
    t.integer "course_id"
    t.integer "discipline_class_offer_id"
    t.index ["course_id"], name: "index_course_class_offers_on_course_id", using: :btree
    t.index ["discipline_class_offer_id"], name: "index_course_class_offers_on_discipline_class_offer_id", using: :btree
  end

  create_table "course_disciplines", force: :cascade do |t|
    t.integer  "semester"
    t.string   "nature",        limit: 3
    t.integer  "course_id"
    t.integer  "discipline_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["course_id"], name: "index_course_disciplines_on_course_id", using: :btree
    t.index ["discipline_id"], name: "index_course_disciplines_on_discipline_id", using: :btree
  end

  create_table "courses", force: :cascade do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "curriculum"
    t.integer  "area_id"
    t.index ["area_id"], name: "index_courses_on_area_id", using: :btree
    t.index ["code"], name: "index_courses_on_code", using: :btree
  end

  create_table "department_courses", force: :cascade do |t|
    t.integer  "department_id"
    t.integer  "course_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["course_id"], name: "index_department_courses_on_course_id", using: :btree
    t.index ["department_id"], name: "index_department_courses_on_department_id", using: :btree
  end

  create_table "departments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "discipline_class_offers", force: :cascade do |t|
    t.integer "discipline_class_id"
    t.integer "vacancies"
    t.index ["discipline_class_id"], name: "index_discipline_class_offers_on_discipline_class_id", using: :btree
  end

  create_table "discipline_classes", force: :cascade do |t|
    t.integer "discipline_id"
    t.string  "class_number"
    t.index ["discipline_id"], name: "index_discipline_classes_on_discipline_id", using: :btree
  end

  create_table "discipline_codes", force: :cascade do |t|
    t.string   "from_code"
    t.string   "to_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "disciplines", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "curriculum"
    t.integer  "load"
    t.index ["code"], name: "index_disciplines_on_code", using: :btree
  end

  create_table "disciplines_enrollments", force: :cascade do |t|
    t.integer  "pre_enrollment_id"
    t.string   "code"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["pre_enrollment_id"], name: "index_disciplines_enrollments_on_pre_enrollment_id", using: :btree
  end

  create_table "disciplines_historics", force: :cascade do |t|
    t.string   "code"
    t.integer  "workload"
    t.integer  "credits"
    t.decimal  "note"
    t.string   "result"
    t.integer  "historic_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.string   "nt"
    t.index ["historic_id"], name: "index_disciplines_historics_on_historic_id", using: :btree
  end

  create_table "disciplines_plannings", force: :cascade do |t|
    t.integer  "planning_id"
    t.string   "code"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["planning_id"], name: "index_disciplines_plannings_on_planning_id", using: :btree
  end

  create_table "historics", force: :cascade do |t|
    t.integer  "year"
    t.integer  "period"
    t.integer  "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_historics_on_student_id", using: :btree
  end

  create_table "orientations", force: :cascade do |t|
    t.string   "name"
    t.string   "matricula"
    t.integer  "professor_user_id"
    t.integer  "course_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["course_id"], name: "index_orientations_on_course_id", using: :btree
    t.index ["professor_user_id"], name: "index_orientations_on_professor_user_id", using: :btree
  end

  create_table "plannings", force: :cascade do |t|
    t.integer  "student_id"
    t.integer  "year"
    t.integer  "period"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_plannings_on_student_id", using: :btree
  end

  create_table "pre_enrollments", force: :cascade do |t|
    t.integer  "year"
    t.integer  "period"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "course_id"
    t.integer  "coordinator_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["coordinator_id"], name: "index_pre_enrollments_on_coordinator_id", using: :btree
    t.index ["course_id"], name: "index_pre_enrollments_on_course_id", using: :btree
  end

  create_table "pre_requisites", force: :cascade do |t|
    t.integer  "pre_discipline_id"
    t.integer  "post_discipline_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["post_discipline_id"], name: "index_pre_requisites_on_post_discipline_id", using: :btree
    t.index ["pre_discipline_id"], name: "index_pre_requisites_on_pre_discipline_id", using: :btree
  end

  create_table "professor_schedules", force: :cascade do |t|
    t.integer "schedule_id"
    t.integer "professor_id"
    t.index ["professor_id"], name: "index_professor_schedules_on_professor_id", using: :btree
    t.index ["schedule_id"], name: "index_professor_schedules_on_schedule_id", using: :btree
  end

  create_table "professor_users", force: :cascade do |t|
    t.string   "name"
    t.integer  "department_id"
    t.string   "username"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["department_id"], name: "index_professor_users_on_department_id", using: :btree
    t.index ["user_id"], name: "index_professor_users_on_user_id", unique: true, using: :btree
  end

  create_table "professors", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_professors_on_name", using: :btree
  end

  create_table "record_enrollments", force: :cascade do |t|
    t.integer  "pre_enrollment_id"
    t.integer  "student_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["pre_enrollment_id"], name: "index_record_enrollments_on_pre_enrollment_id", using: :btree
    t.index ["student_id"], name: "index_record_enrollments_on_student_id", using: :btree
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "day"
    t.integer "start_hour"
    t.integer "start_minute"
    t.integer "discipline_class_id"
    t.integer "end_hour"
    t.integer "end_minute"
    t.integer "first_class_number"
    t.integer "class_count"
    t.index ["discipline_class_id"], name: "index_schedules_on_discipline_class_id", using: :btree
  end

  create_table "semesters", force: :cascade do |t|
    t.integer  "year"
    t.integer  "period"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students", force: :cascade do |t|
    t.string   "name"
    t.string   "matricula"
    t.string   "email"
    t.integer  "course_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_students_on_course_id", using: :btree
    t.index ["user_id"], name: "index_students_on_user_id", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",           default: "",    null: false
    t.integer  "rule",               default: 0
    t.boolean  "enable",             default: false
    t.integer  "sign_in_count",      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  add_foreign_key "association_enrollments", "disciplines_enrollments"
  add_foreign_key "association_enrollments", "record_enrollments"
  add_foreign_key "coordinators", "courses"
  add_foreign_key "coordinators", "users"
  add_foreign_key "course_class_offers", "courses"
  add_foreign_key "course_class_offers", "discipline_class_offers"
  add_foreign_key "course_disciplines", "courses"
  add_foreign_key "course_disciplines", "disciplines"
  add_foreign_key "department_courses", "courses"
  add_foreign_key "department_courses", "departments"
  add_foreign_key "discipline_class_offers", "discipline_classes"
  add_foreign_key "discipline_classes", "disciplines"
  add_foreign_key "disciplines_enrollments", "pre_enrollments"
  add_foreign_key "disciplines_historics", "historics"
  add_foreign_key "disciplines_plannings", "plannings"
  add_foreign_key "historics", "students"
  add_foreign_key "orientations", "courses"
  add_foreign_key "orientations", "professor_users"
  add_foreign_key "plannings", "students"
  add_foreign_key "pre_enrollments", "coordinators"
  add_foreign_key "pre_enrollments", "courses"
  add_foreign_key "pre_requisites", "course_disciplines", column: "post_discipline_id"
  add_foreign_key "pre_requisites", "course_disciplines", column: "pre_discipline_id"
  add_foreign_key "professor_schedules", "professors"
  add_foreign_key "professor_schedules", "schedules"
  add_foreign_key "professor_users", "departments"
  add_foreign_key "professor_users", "users"
  add_foreign_key "record_enrollments", "pre_enrollments"
  add_foreign_key "record_enrollments", "students"
  add_foreign_key "schedules", "discipline_classes"
  add_foreign_key "students", "courses"
  add_foreign_key "students", "users"
end
