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

ActiveRecord::Schema.define(:version => 20111208091241) do

  create_table "agents", :force => true do |t|
    t.column "type", :string
    t.column "world_id", :integer
    t.column "resource_tile_id", :integer
    t.column "x", :float
    t.column "y", :float
    t.column "properties", :text
    t.column "heading", :integer
    t.column "geom", :point, :srid => 4326
  end

  add_index "agents", ["geom"], :name => "index_agents_on_geom", :spatial=> true 
  add_index "agents", ["resource_tile_id"], :name => "index_agents_on_resource_tile_id"
  add_index "agents", ["type"], :name => "index_agents_on_type"
  add_index "agents", ["world_id"], :name => "index_agents_on_world_id"
  add_index "agents", ["x"], :name => "index_agents_on_x"
  add_index "agents", ["y"], :name => "index_agents_on_y"

  create_table "bids", :force => true do |t|
    t.column "listing_id", :integer
    t.column "bidder_id", :integer
    t.column "current_owner_id", :integer
    t.column "money", :integer
    t.column "offered_land_id", :integer
    t.column "requested_land_id", :integer
    t.column "status", :string, :default => "Offered"
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "rejection_reason", :string
    t.column "counter_to_id", :integer
    t.column "lock_version", :integer, :default => 0
    t.column "execution_complete", :boolean, :default => false
  end

  add_index "bids", ["listing_id"], :name => "index_bids_on_listing_id"

  create_table "change_requests", :force => true do |t|
    t.column "type", :string
    t.column "target_id", :integer
    t.column "target_type", :string
    t.column "development_type", :string
    t.column "development_quality", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "complete", :boolean, :default => false
    t.column "world_id", :integer
  end

  add_index "change_requests", ["complete"], :name => "index_change_requests_on_complete"
  add_index "change_requests", ["world_id"], :name => "index_change_requests_on_world_id"

  create_table "listings", :force => true do |t|
    t.column "owner_id", :integer
    t.column "megatile_grouping_id", :integer
    t.column "price", :integer
    t.column "notes", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "status", :string, :default => "Active"
    t.column "bid_id", :integer
    t.column "lock_version", :integer, :default => 0
  end

  add_index "listings", ["owner_id"], :name => "index_listings_on_owner_id"

  create_table "megatile_groupings", :force => true do |t|
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "megatile_groupings_megatiles", :force => true do |t|
    t.column "megatile_id", :integer
    t.column "megatile_grouping_id", :integer
  end

  create_table "megatiles", :force => true do |t|
    t.column "world_id", :integer
    t.column "x", :integer
    t.column "y", :integer
    t.column "owner_id", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "lock_version", :integer, :default => 0
  end

  create_table "players", :force => true do |t|
    t.column "user_id", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "world_id", :integer
    t.column "balance", :integer
    t.column "type", :string
    t.column "lock_version", :integer, :default => 0
  end

  create_table "resource_tiles", :force => true do |t|
    t.column "megatile_id", :integer
    t.column "x", :integer
    t.column "y", :integer
    t.column "type", :string
    t.column "zoned_use", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "world_id", :integer
    t.column "lock_version", :integer, :default => 0
    t.column "primary_use", :string
    t.column "people_density", :float
    t.column "housing_density", :float
    t.column "tree_density", :float
    t.column "tree_species", :string
    t.column "development_intensity", :float
    t.column "tree_size", :float
    t.column "imperviousness", :float
    t.column "frontage", :float
    t.column "lakesize", :float
    t.column "soil", :integer
  end

  create_table "users", :force => true do |t|
    t.column "name", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "email", :string, :default => "", :null => false
    t.column "encrypted_password", :string, :limit => 128, :default => "", :null => false
    t.column "reset_password_token", :string
    t.column "reset_password_sent_at", :datetime
    t.column "remember_created_at", :datetime
    t.column "sign_in_count", :integer, :default => 0
    t.column "current_sign_in_at", :datetime
    t.column "last_sign_in_at", :datetime
    t.column "current_sign_in_ip", :string
    t.column "last_sign_in_ip", :string
    t.column "authentication_token", :string
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.column "versioned_id", :integer
    t.column "versioned_type", :string
    t.column "user_id", :integer
    t.column "user_type", :string
    t.column "user_name", :string
    t.column "modifications", :text
    t.column "number", :integer
    t.column "reverted_from", :integer
    t.column "tag", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

  create_table "worlds", :force => true do |t|
    t.column "name", :string
    t.column "year_start", :integer
    t.column "year_current", :integer
    t.column "height", :integer
    t.column "width", :integer
    t.column "megatile_width", :integer
    t.column "megatile_height", :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

end
