set :rails_env, :staging
set :branch, "armored_armadillo"
set :deploy_to, "/var/www/#{application}"

# CRON JOBS
set :whenever_command, "bundle exec whenever"
set :whenever_environment, defer { stage }
require "whenever/capistrano"

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
    run "god restart trails_forward"
  end
end
