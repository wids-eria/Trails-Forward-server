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

ActiveRecord::Schema.define(:version => 20121029183945) do

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

  create_table "contract_attached_megatiles", :force => true do |t|
    t.integer "contract_id"
    t.integer "megatile_id"
  end

  create_table "contract_included_megatiles", :force => true do |t|
    t.integer "contract_id"
    t.integer "megatile_id"
  end

  create_table "contract_templates", :force => true do |t|
    t.integer  "world_id"
    t.string   "codename"
    t.string   "role"
    t.string   "difficulty"
    t.integer  "points_required_to_unlock"
    t.integer  "points"
    t.integer  "dollars"
    t.integer  "deadline"
    t.text     "description"
    t.text     "acceptance_message"
    t.text     "complete_message"
    t.text     "late_message"
    t.boolean  "includes_land",             :default => false
    t.integer  "volume_required"
    t.string   "wood_type"
    t.integer  "acres_added_required"
    t.integer  "acres_developed_required"
    t.string   "home_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
  end

  create_table "contracts", :force => true do |t|
    t.integer  "contract_template_id"
    t.integer  "world_id"
    t.integer  "player_id"
    t.integer  "month_started"
    t.integer  "month_ended"
    t.boolean  "ended"
    t.boolean  "successful"
    t.boolean  "on_time"
    t.integer  "volume_harvested_of_required_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "points_earned"
  end

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

  create_table "logging_equipment_templates", :force => true do |t|
    t.string   "name"
    t.string   "equipment_type"
    t.text     "market_description"
    t.integer  "initial_cost_min"
    t.integer  "initial_cost_max"
    t.integer  "operating_cost_min"
    t.integer  "operating_cost_max"
    t.integer  "maintenance_cost_min"
    t.integer  "maintenance_cost_max"
    t.integer  "harvest_volume_min"
    t.integer  "harvest_volume_max"
    t.integer  "diameter_range_min"
    t.integer  "diameter_range_max"
    t.integer  "yarding_volume_min"
    t.integer  "yarding_volume_max"
    t.integer  "transport_volume_min"
    t.integer  "transport_volume_max"
    t.integer  "condition_min"
    t.integer  "condition_max"
    t.integer  "reliability_min"
    t.integer  "reliability_max"
    t.integer  "decay_rate_min"
    t.integer  "decay_rate_max"
    t.integer  "scrap_value_min"
    t.integer  "scrap_value_max"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logging_equipments", :force => true do |t|
    t.string   "name"
    t.string   "equipment_type"
    t.float    "initial_cost"
    t.float    "operating_cost"
    t.float    "maintenance_cost"
    t.float    "harvest_volume"
    t.integer  "diameter_range_min"
    t.integer  "diameter_range_max"
    t.float    "yarding_volume"
    t.float    "transport_volume"
    t.float    "condition"
    t.float    "reliability"
    t.float    "decay_rate"
    t.float    "scrap_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "market_description"
    t.integer  "logging_equipment_id"
    t.integer  "world_id"
    t.integer  "player_id"
  end

  create_table "megatile_groupings", :force => true do |t|
  end

  create_table "megatile_groupings_megatiles", :force => true do |t|
    t.integer "megatile_id"
    t.integer "megatile_grouping_id"
  end

  create_table "megatiles", :force => true do |t|
    t.integer  "world_id"
    t.integer  "x"
    t.integer  "y"
    t.integer  "owner_id"
    t.integer  "megatile_region_cache_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "megatiles", ["megatile_region_cache_id", "updated_at"], :name => "index_megatiles_on_megatile_region_cache_id_and_updated_at"
  add_index "megatiles", ["world_id", "updated_at"], :name => "index_megatiles_on_world_id_and_updated_at"

  create_table "messages", :force => true do |t|
    t.text     "subject"
    t.text     "body"
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.datetime "read_at"
    t.datetime "archived_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "non_player_characters", :force => true do |t|
    t.string   "type"
    t.integer  "world_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer "housing_occupants",          :default => 0
    t.boolean "harvest_area",               :default => false
    t.integer "supported_saplings",         :default => 0
    t.string  "tree_type",                  :default => "none"
    t.boolean "outpost",                    :default => false
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
    t.float   "marten_population",          :default => 0.0
    t.float   "vole_population",            :default => 0.0
    t.string  "housing_type"
  end

  add_index "resource_tiles", ["megatile_id"], :name => "index_resource_tiles_on_megatile_id"
  add_index "resource_tiles", ["world_id", "type"], :name => "index_resource_tiles_on_world_id_and_type"
  add_index "resource_tiles", ["world_id", "x", "y"], :name => "index_resource_tiles_on_world_id_and_x_and_y", :unique => true

  create_table "resources", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", :force => true do |t|
    t.date     "capture_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "num_2in_trees",  :default => 0.0
    t.float    "num_4in_trees",  :default => 0.0
    t.float    "num_6in_trees",  :default => 0.0
    t.float    "num_8in_trees",  :default => 0.0
    t.float    "num_10in_trees", :default => 0.0
    t.float    "num_12in_trees", :default => 0.0
    t.float    "num_14in_trees", :default => 0.0
    t.float    "num_16in_trees", :default => 0.0
    t.float    "num_18in_trees", :default => 0.0
    t.float    "num_20in_trees", :default => 0.0
    t.float    "num_22in_trees", :default => 0.0
    t.float    "num_24in_trees", :default => 0.0
    t.integer  "player_id"
    t.integer  "megatile_id"
    t.float    "vol_2in_trees"
    t.float    "vol_4in_trees"
    t.float    "vol_6in_trees"
    t.float    "vol_8in_trees"
    t.float    "vol_10in_trees"
    t.float    "vol_12in_trees"
    t.float    "vol_14in_trees"
    t.float    "vol_16in_trees"
    t.float    "vol_18in_trees"
    t.float    "vol_20in_trees"
    t.float    "vol_22in_trees"
    t.float    "vol_24in_trees"
  end

  add_index "surveys", ["megatile_id"], :name => "index_surveys_on_megatile_id"
  add_index "surveys", ["player_id"], :name => "index_surveys_on_player_id"

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
    t.integer  "current_turn",                      :default => 1
    t.datetime "turn_started_at"
    t.string   "turn_state",                        :default => "play"
    t.integer  "turn_duration",                     :default => 15
    t.integer  "year_current",                      :default => 0
    t.float    "pine_sawtimber_base_price"
    t.float    "pine_sawtimber_supply_coefficient"
    t.float    "pine_sawtimber_demand_coefficient"
    t.integer  "pine_sawtimber_min_price"
    t.integer  "pine_sawtimber_max_price"
    t.float    "pine_sawtimber_cut_this_turn",      :default => 0.0
    t.float    "pine_sawtimber_used_this_turn",     :default => 0.0
  end

end
