set :rvm_ruby_string, '1.9.2'
set :rvm_type, :system

require 'bundler/capistrano'
load 'deploy/assets'


set :whenever_command, "bundle exec whenever"
set :whenever_environment, defer { stage }
require "whenever/capistrano"


require 'capistrano/ext/multistage'
set :stages, %w(production staging)
set :default_stage, "staging"

set :application, "trails_forward"
set :repository,  "git@github.com:wids-eria/Trails-Forward-server.git"

set :scm, :git

set :user, :deploy
ssh_options[:forward_agent] = true

role :web, "eria-1.morgridge.net"
role :app, "eria-1.morgridge.net"
role :db,  "eria-1.morgridge.net", :primary => true # This is where Rails migrations will run

set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :normalize_asset_timestamps, false

# CALLBACKS #########

after 'deploy:finalize_update', 'deploy:symlink_db'
after 'deploy:finalize_update', 'deploy:symlink_world_images'

namespace :deploy do
  desc "Symlinks the database.yml"
  task :symlink_db, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/shared/config/crossdomain.xml #{release_path}/public/crossdomain.xml"
  end

  task :symlink_world_images, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/worlds/ #{release_path}/public/worlds"
    run "ln -nfs #{deploy_to}/shared/asset_packages/ #{release_path}/public/images/asset_packages"
  end

  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
    run "god restart trails_forward trails_forward_staging"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  task :cold do       # Overriding the default deploy:cold
    update
    load_schema       # My own step, replacing migrations.
    start
  end

  desc "Load schema.rb into database"
  task :load_schema, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake db:schema:load"
  end
end
