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

ActiveRecord::Schema.define(:version => 20110715145044) do

  create_table "bids", :force => true do |t|
    t.integer  "listing_id"
    t.integer  "bidder_id"
    t.integer  "current_owner_id"
    t.integer  "money"
    t.integer  "offered_land_id"
    t.integer  "requested_land_id"
    t.string   "status",             :default => "Offered"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rejection_reason"
    t.integer  "counter_to_id"
    t.integer  "lock_version",       :default => 0
    t.boolean  "execution_complete", :default => false
  end

  add_index "bids", ["listing_id"], :name => "index_bids_on_listing_id"

  create_table "change_requests", :force => true do |t|
    t.string   "type"
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "development_type"
    t.string   "development_quality"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "complete",            :default => false
    t.integer  "world_id"
  end

  add_index "change_requests", ["complete"], :name => "index_change_requests_on_complete"
  add_index "change_requests", ["world_id"], :name => "index_change_requests_on_world_id"

  create_table "listings", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "megatile_grouping_id"
    t.integer  "price"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",               :default => "Active"
    t.integer  "bid_id"
    t.integer  "lock_version",         :default => 0
  end

  add_index "listings", ["owner_id"], :name => "index_listings_on_owner_id"

  create_table "megatile_grouping_megatiles", :force => true do |t|
    t.integer  "megatile_grouping_id"
    t.integer  "megatile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "megatile_groupings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "megatiles", :force => true do |t|
    t.integer  "world_id"
    t.integer  "x"
    t.integer  "y"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
  end

  add_index "megatiles", ["owner_id"], :name => "index_megatiles_on_owner_id"
  add_index "megatiles", ["world_id"], :name => "index_megatiles_on_world_id"
  add_index "megatiles", ["x"], :name => "index_megatiles_on_x"
  add_index "megatiles", ["y"], :name => "index_megatiles_on_y"

  create_table "players", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "world_id"
    t.integer  "balance"
    t.string   "type"
    t.integer  "lock_version", :default => 0
  end

  create_table "resource_tiles", :force => true do |t|
    t.integer  "megatile_id"
    t.integer  "x"
    t.integer  "y"
    t.string   "type"
    t.string   "zoned_use"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "world_id"
    t.integer  "lock_version",          :default => 0
    t.string   "primary_use"
    t.float    "people_density"
    t.float    "housing_density"
    t.float    "tree_density"
    t.string   "tree_species"
    t.float    "development_intensity"
    t.float    "tree_size"
    t.float    "imperviousness"
    t.float    "frontage"
    t.float    "lakesize"
    t.integer  "soil"
  end

  add_index "resource_tiles", ["megatile_id"], :name => "index_resource_tiles_on_megatile_id"
  add_index "resource_tiles", ["world_id"], :name => "index_resource_tiles_on_world_id"
  add_index "resource_tiles", ["x"], :name => "index_resource_tiles_on_x"
  add_index "resource_tiles", ["y"], :name => "index_resource_tiles_on_y"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "modifications"
    t.integer  "number"
    t.integer  "reverted_from"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

  create_table "worlds", :force => true do |t|
    t.string   "name"
    t.integer  "year_start"
    t.integer  "year_current"
    t.integer  "height"
    t.integer  "width"
    t.integer  "megatile_width"
    t.integer  "megatile_height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
