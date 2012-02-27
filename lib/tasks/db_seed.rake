namespace :db do
  namespace :seed do
    require Rails.root.join('db/seed_tables.rb')

    desc "dump the tables holding seed data to db/RAILS_ENV_seed.sql. SEED_TABLES need to be defined in db/seed_tables.rb!"
    task :dump => :environment do
      config = ActiveRecord::Base.configurations[Rails.env]
      dump_cmd = "mysqldump --user=#{config['username']} --password=#{config['password']} #{config['database']} #{SEED_TABLES.join(" ")} > db/#{Rails.env}_seed.sql"
      system(dump_cmd)
    end

    desc "load the dumped seed data from db/development_seed.sql into the database"
    task :load => :environment do
      config = ActiveRecord::Base.configurations[Rails.env]
      system("mysql --user=#{config['username']} --password=#{config['password']} #{config['database']} < db/#{Rails.env}_seed.sql")
     end
  end
end
