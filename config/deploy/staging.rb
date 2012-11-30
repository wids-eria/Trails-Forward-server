set :rails_env, :staging
set :branch, "master"
set :deploy_to, "/var/www/#{application}_bleeding"

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
