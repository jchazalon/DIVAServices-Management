require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application, 'divaa'
set :domain, '46.101.197.192'
set :user, 'apps'
set :forward_agent, true
set :term_mode, nil
set :gemset, 'ruby-2.1.5@default'
set :deploy_to, '/home/apps/divaa'
set :repository, 'git@bitbucket.org:StupidBird/diva_algorithm.git'
set :branch, 'mina'
set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log', 'public/uploads', '.env']
set :rails_env, 'production'

task :environment do
  invoke :"rvm:use[#{gemset}]"
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/public/uploads"]

  queue! %[touch "#{deploy_to}/#{shared_path}/.env"]

  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml' and 'secrets.yml' and '.env'."]
end

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

task :seed => :environment do
  in_directory "#{deploy_to}/#{current_path!}" do
    queue! "RAILS_ENV=production bundle exec rake db:seed"
  end
end

task :reset_db => :environment do
  in_directory "#{deploy_to}/#{current_path!}" do
    queue "echo '-----> Stopping Thin'"
    queue "bundle exec thin stop -C /etc/thin/#{application}.yml"
    queue! "RAILS_ENV=production bundle exec rake db:drop db:create db:migrate"
    queue "echo '-----> Starting Thin on socket'"
    queue "bundle exec thin start -C /etc/thin/#{application}.yml"
  end
end

task :start => :environment do
  log "Starting thin"
  in_directory "#{deploy_to}/#{current_path!}" do
    queue "echo '-----> Starting Thin on socket'"
    queue "bundle exec thin start -C /etc/thin/#{application}.yml"
  end
end

task :stop => :environment do
  log "Stopping thin"
  in_directory "#{deploy_to}/#{current_path!}" do
    queue "echo '-----> Stopping Thin'"
    queue "bundle exec thin stop -C /etc/thin/#{application}.yml"
  end
end

task :restart => :environment do
  log "Restarting thin"
  in_directory "#{deploy_to}/#{current_path!}" do
    queue "echo '-----> Restarting Thin'"
    queue "bundle exec thin restart -C /etc/thin/#{application}.yml"
  end
end
