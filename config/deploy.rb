# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "myapp"
set :repo_url, "git@github.com:newaaz/Blog-master.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, "main"

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, "/home/deploy/#{fetch :application}"

set :ssh_options, {
  verify_host_key: :never
}

# namespace :deploy do
#   desc 'Fix permissions'
#   task :fix_permissions do
#     on roles(:app) do
#       execute :sudo, :chown, '-R', "#{fetch(:user)}:#{fetch(:user)}", fetch(:deploy_to)
#       execute :sudo, :chmod, '-R', '755', fetch(:deploy_to)
#       execute "chmod -R 775 #{shared_path}/log #{shared_path}/tmp #{current_path}/log #{current_path}/tmp"
#     end
#   end
#
#   after :publishing, :fix_permissions
# end

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'tmp/storage', 'vendor/bundle',
       '.bundle', 'public/system', 'storage', 'public/uploads'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
