require 'bundler/capistrano' # enable bundler stuff!
require 'capistrano/ext/multistage'
set :stages, %w(production staging)
set :default_stage, "production"

load 'deploy/assets'

# rvm stuff
#$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.3-p194'        # Or whatever env you want it to run in.
set :rvm_type, :user
###

set(:deploy_to) { File.join("", "home", user, "sites", application) }
set :config_files, %w(mongoid.yml)

default_run_options[:pty] = true

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]

server "digitalsocial.eu", :app, :web, :db, :primary => true

set :repository,  "git@github.com:Swirrl/linked_development_pmd.git"
set :scm, "git"
set :ssh_options, {:forward_agent => true, :keys => "~/.ssh/id_rsa" }
set :user, "rails"
set :runner, "rails"
set :admin_runner, "rails"
set :use_sudo, false

set :deploy_via, :remote_cache

after "deploy:setup", "deploy:upload_app_config"
after 'deploy:setup', 'deploy:make_shared_config_dir'
after 'deploy:setup', 'deploy:transfer_production_config'

before 'deploy:assets:precompile', 'deploy:symlink_shared_config'
after "deploy:finalize_update", "deploy:symlink_app_config"

namespace :deploy do

  task :make_shared_config_dir do
    run "mkdir #{shared_path}/configs"
  end

  desc 'Copy the production config files to the shared folder - so they can be symlinked in later'
  task :transfer_production_config do
    top.upload(File.join('config', 'environments', 'production.rb'),
               File.join(shared_path, 'configs', 'production.rb'))
  end

  task :symlink_shared_config do
    run("ln -s " + File.join(shared_path,  'configs', 'production.rb') + " " +
                   File.join(release_path, 'config', 'environments', 'production.rb'))
  end

  desc <<-DESC
    overriding deploy:cold task to not migrate...
  DESC
  task :cold do
    update
    start
  end

  desc <<-DESC
    overriding start to just call restart
  DESC
  task :start do
    restart
  end

  desc <<-DESC
    overriding stop to do nothing - you cant stop a passenger app!
  DESC
  task :stop do
  end

  desc "Copy local config files from app's config folder to shared_path."
  task :upload_app_config do
    config_files.each { |filename| put(File.read("config/#{filename}"), "#{shared_path}/#{filename}", :mode => 0640) }
  end

  desc "Symlink the application's config files specified in :config_files to the latest release"
  task :symlink_app_config do
    config_files.each { |filename| run "ln -nfs #{shared_path}/#{filename} #{latest_release}/config/#{filename}" }
  end

  desc <<-DESC
  overriding start to just touch the restart txt
  DESC
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
    run "echo 'flush_all' | nc localhost 11215" # flush memcached 11215 is the linkeddev memcached
  end
end

require './config/boot'
