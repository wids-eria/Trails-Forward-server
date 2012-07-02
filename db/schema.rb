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

ActiveRecord::Schema.define(:version => 20120702185304) do

  create_table "agent_settings", :force => true do |t|
    t.integer "agent_id", :null => false
    t.string  "name",     :null => false
    t.string  "value"
  end

  add_index "agent_settings", ["agent_id", "name"], :name => "index_agent_settings_on_agent_id_and_name", :unique => true

  create_table "agents", :force => true do |t|
    t.string  "type"
    t.integer "world_id"
    t.integer "resource_tile_id"
    t.float   "x"
    t.float   "y"
    t.float   "heading"
    t.string  "state"
    t.integer "age",              :default => 0
  end

  add_index "agents", ["x", "y", "world_id"], :name => "index_agents_on_x_and_y_and_world_id"

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
  end

  add_index "listings", ["owner_id"], :name => "index_listings_on_owner_id"

  create_table "megatile_groupings", :force => true do |t|
  end

  create_table "megatile_groupings_megatiles", :force => true do |t|
    t.integer "megatile_id"
    t.integer "megatile_grouping_id"
  end

  create_table "megatile_region_caches", :force => true do |t|
    t.integer  "world_id"
    t.integer  "x_min"
    t.integer  "x_max"
    t.integer  "y_min"
    t.integer  "y_max"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "megatiles", :force => true do |t|
    t.integer "world_id"
    t.integer "x"
    t.integer "y"
    t.integer "owner_id"
    t.integer "megatile_region_cache_id"
  end

  create_table "players", :force => true do |t|
    t.integer  "user_id"
    t.integer  "world_id"
    t.integer  "balance",             :default => 0
    t.string   "type"
    t.integer  "last_turn_played",    :default => 0
    t.datetime "last_turn_played_at"
    t.integer  "quest_points",        :default => 0
    t.integer  "pending_balance",     :default => 0
    t.text     "quests"
  end

  create_table "resource_tiles", :force => true do |t|
    t.integer "megatile_id"
    t.integer "x"
    t.integer "y"
    t.string  "type"
    t.integer "world_id"
    t.string  "primary_use"
    t.float   "people_density"
    t.float   "housing_density"
    t.float   "tree_density"
    t.float   "development_intensity"
    t.float   "tree_size"
    t.float   "imperviousness"
    t.float   "frontage"
    t.float   "lakesize"
    t.integer "soil"
    t.integer "landcover_class_code"
    t.integer "zoning_code"
    t.float   "num_2_inch_diameter_trees",  :default => 0.0,    :null => false
    t.float   "num_4_inch_diameter_trees",  :default => 0.0,    :null => false
    t.float   "num_6_inch_diameter_trees",  :default => 0.0,    :null => false
    t.float   "num_8_inch_diameter_trees",  :default => 0.0,    :null => false
    t.float   "num_10_inch_diameter_trees", :default => 0.0,    :null => false
    t.float   "num_12_inch_diameter_trees", :default => 0.0,    :null => false
    t.float   "num_14_inch_diameter_trees", :default => 0.0,    :null => false
    t.float   "num_16_inch_diameter_trees", :default => 0.0,    :null => false
    t.float   "num_18_inch_diameter_trees", :default => 0.0,    :null => false
    t.float   "num_20_inch_diameter_trees", :default => 0.0,    :null => false
    t.float   "num_22_inch_diameter_trees", :default => 0.0,    :null => false
    t.float   "num_24_inch_diameter_trees", :default => 0.0,    :null => false
    t.string  "zone_type",                  :default => "none"
    t.integer "housing_capacity",           :default => 0
    t.integer "housing_occupants",          :default => 0
    t.boolean "harvest_area",               :default => false
    t.integer "supported_saplings",         :default => 0
    t.string  "tree_type",                  :default => "none"
    t.boolean "outpost",                    :default => false
    t.text    "residue"
    t.text    "population"
    t.float   "local_desirability_score",   :default => 0.0
    t.float   "total_desirability_score",   :default => 0.0
    t.boolean "can_be_surveyed",            :default => false
    t.boolean "is_surveyed",                :default => false
    t.boolean "bought_by_developer",        :default => false
    t.boolean "bought_by_timber_company",   :default => false
    t.boolean "outpost_requested",          :default => false
    t.boolean "survey_requested",           :default => false
    t.integer "marten_suitability",         :default => 0
    t.float   "small_tree_basal_area"
    t.float   "large_tree_basal_area"
  end

  add_index "resource_tiles", ["megatile_id"], :name => "index_resource_tiles_on_megatile_id"
  add_index "resource_tiles", ["world_id", "type"], :name => "index_resource_tiles_on_world_id_and_type"
  add_index "resource_tiles", ["world_id", "x", "y"], :name => "index_resource_tiles_on_world_id_and_x_and_y", :unique => true

  create_table "resources", :force => true do |t|
    t.string  "type"
    t.float   "value"
    t.integer "world_id"
    t.integer "resource_tile_id"
  end

  create_table "surveys", :force => true do |t|
    t.date     "capture_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tile_surveys", :force => true do |t|
    t.float    "poletimber_value"
    t.float    "sawtimber_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "worlds", :force => true do |t|
    t.string   "name"
    t.integer  "height"
    t.integer  "width"
    t.integer  "megatile_width"
    t.integer  "megatile_height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "current_date"
    t.integer  "current_turn",    :default => 1
    t.datetime "turn_started_at"
    t.integer  "timber_count",    :default => 0
    t.string   "turn_state",      :default => "play"
    t.integer  "turn_duration",   :default => 15
  end

end
