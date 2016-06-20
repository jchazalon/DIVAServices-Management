require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'

# Please make sure to edit the following variables:

# Application name on host
set :application, 'divaa'
# Hostname where to deploy the application
set :domain, '46.101.197.192'
# User on the host
set :user, 'apps'
set :forward_agent, true
set :term_mode, nil
set :gemset, 'ruby-2.1.5@default'
# Folder to deploy to
set :deploy_to, '/home/apps/divaa'
# Repository that is pulled
set :repository, 'git@bitbucket.org:StupidBird/diva_algorithm.git'
# Branch where the newest commit is taken from
set :branch, 'master'
set :shared_paths, ['log', 'public/uploads', '.env'] # 'config/database.yml', 'config/secrets.yml' should not be needed
set :rails_env, 'production'

##
# Define gemset.
task :environment do
  invoke :"rvm:use[#{gemset}]"
end

##
# Initially create the shared folders.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]
  # Not necessary to have shared db and secrets as long as we use the .env file!
  # queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  # queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]
  # queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  # queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/public/uploads"]
  queue! %[touch "#{deploy_to}/#{shared_path}/.env"]
  queue  %[echo "-----> Be sure to edit '.env'."]
end

##
# Deploy the newest commit.
desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    queue! "RACK_ENV=production bundle exec rake db:create && echo ''"
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'
    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
    end
  end
end

##
# Seed the production part of the seeds.rb file.
task :seed => :environment do
  in_directory "#{deploy_to}/#{current_path!}" do
    queue! "RAILS_ENV=production bundle exec rake db:seed"
  end
end

##
# Reset the database (You really shouldn't do that in production!).
task :reset_db => :environment do
  in_directory "#{deploy_to}/#{current_path!}" do
    queue "echo '-----> Stopping Thin'"
    queue "bundle exec thin stop -C /etc/thin/#{application}.yml"
    queue "RAILS_ENV=production bin/delayed_job stop"
    queue! "RAILS_ENV=production bundle exec rake db:drop db:create db:migrate"
    queue "echo '-----> Starting Thin on socket'"
    queue "bundle exec thin start -C /etc/thin/#{application}.yml"
    queue "RAILS_ENV=production bin/delayed_job start"
  end
end

##
# Start the application on the production server.
task :start => :environment do
  log "Starting thin"
  in_directory "#{deploy_to}/#{current_path!}" do
    queue "echo '-----> Starting Thin on socket'"
    queue "bundle exec thin start -C /etc/thin/#{application}.yml"
    queue "RAILS_ENV=production bin/delayed_job start"
  end
end

##
# Stop the application on the production server.
task :stop => :environment do
  log "Stopping thin"
  in_directory "#{deploy_to}/#{current_path!}" do
    queue "echo '-----> Stopping Thin'"
    queue "bundle exec thin stop -C /etc/thin/#{application}.yml"
    queue "RAILS_ENV=production bin/delayed_job stop"
  end
end

##
# Restart the application on the production server.
task :restart => :environment do
  log "Restarting thin"
  in_directory "#{deploy_to}/#{current_path!}" do
    queue "echo '-----> Restarting Thin'"
    queue "bundle exec thin restart -C /etc/thin/#{application}.yml"
    queue "RAILS_ENV=production bin/delayed_job restart"
  end
end
