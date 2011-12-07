namespace :gis do
  desc "setup GIS table columns and functions"
  task :setup => [:environment] do
    db_name = ActiveRecord::Base.connection.current_database
    system "psql -d #{db_name} -f #{Rails.root.join('db/spatial/lwpostgis.sql')} -q"
    system "psql -d #{db_name} -f #{Rails.root.join('db/spatial/spatial_ref_sys.sql')} -q"
  end
end

task 'db:schema:load' => ['gis:setup']

Rake::Task["db:create"].enhance do
  Rake::Task["gis:setup"].invoke
end
