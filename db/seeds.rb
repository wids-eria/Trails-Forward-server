# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
require Rails.root.join('db/seed_tables.rb')

SEED_TABLES.each do |table_name|
  klass = table_name.classify.constantize
  klass.delete_all
end

Rake::Task['db:seed:load'].invoke
