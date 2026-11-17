class CreateNotes < ActiveRecord::Migration[8.2]
  def change
    create_table "note_activity_spikes", id: :uuid, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.uuid "note_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["note_id"], name: "index_card_activity_spikes_on_card_id"
    end

    create_table "note_engagements", id: :uuid, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.uuid "note_id"
      t.datetime "created_at", null: false
      t.string "status", limit: 255, default: "doing", null: false
      t.datetime "updated_at", null: false
      t.index ["note_id"], name: "index_card_engagements_on_card_id"
      t.index ["status"], name: "index_card_engagements_on_status"
    end

    create_table "note_highlights", id: :uuid, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.uuid "note_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["note_id"], name: "index_card_goldnesses_on_card_id", unique: true
    end

    create_table "note_dismissals", id: :uuid, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.uuid "note_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.uuid "user_id"
      t.index ["note_id"], name: "index_card_not_nows_on_card_id", unique: true
      t.index ["user_id"], name: "index_card_not_nows_on_user_id"
    end

    create_table "notes", id: :uuid, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.uuid "account_id"
      t.uuid "board_id", null: false
      t.uuid "column_id"
      t.datetime "created_at", null: false
      t.uuid "creator_id", null: false
      t.date "due_on"
      t.datetime "last_active_at", null: false
      t.string "status", limit: 255, default: "drafted", null: false
      t.string "title", limit: 255
      t.datetime "updated_at", null: false
      t.index ["board_id"], name: "index_notes_on_board_id"
      t.index ["column_id"], name: "index_notes_on_column_id"
      t.index ["last_active_at", "status"], name: "index_notes_on_last_active_at_and_status"
    end

    add_foreign_key "note_activity_spikes", "notes"
    add_foreign_key "note_highlights", "notes"
    add_foreign_key "note_dismissals", "notes"
    add_foreign_key "note_dismissals", "users"
    add_foreign_key "notes", "columns"
  end
end
