require "bundler/capistrano"
require "rvm/capistrano"

set :application, "where_in_the_world_is_ben"
set :repository,  "git@github.com:rubiety/where_in_the_world_is_ben.git"
set :deploy_to, "/var/www/whereintheworldisben.com"
set :user, "apps"

set :scm, :git
set :git_shallow_clone, 1
set :deploy_via, :remote_cache
set :normalize_asset_timestamps, false
set :use_sudo, false
ssh_options[:forward_agent] = true
ssh_options[:port] = 2234

## Default RVM Ruby (1.9.2)
set :rvm_ruby_string, "ruby-1.9.2-p290"
set :rvm_type, :system

role :web, "www.whereintheworldisben.com"
role :app, "www.whereintheworldisben.com"
role :db,  "www.whereintheworldisben.com", :primary => true
role :db,  "www.whereintheworldisben.com"

## Paths to Symlink
set :symlink_paths, %w(
  config/app.yml
)

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

## Symlinking Shared Assets
namespace :deploy do
  task :symlink_shared do 
    symlink_paths.each do |path|
      run "ln -nfs #{shared_path}/#{path} #{release_path}/#{path}"
    end
  end
end

after "deploy:update_code", "deploy:symlink_shared"
