include_recipe 'build-essential'
mysql_client 'gerrit'
mysql2_chef_gem 'gerrit'

if Chef::Config[:solo]
  pwd = {
    "mysql_root" => "password",
    "gerrit_secure" => {
      "database" => {
        "password" => "gerrit"
      }
    }
  }
else
  chef_gem 'chef-vault'
  require 'chef-vault'
  pwd = chef_vault_item('pipeline', 'secrets').to_hash()
end

mysql_service 'gerrit' do
  port '3306'
  initial_root_password pwd['mysql_root']
  action [:create, :start]
end

connection_info = {
  :host     => '127.0.0.1',
  :username => 'root',
  :password => pwd['mysql_root']
}

mysql_database 'gerrit' do
  connection connection_info
  action :create
end

mysql_database_user 'gerrit' do
  connection connection_info
  password pwd['gerrit_secure']['database']['password']
  action :create
end

mysql_database_user 'gerrit' do
  connection connection_info
  database_name 'gerrit'
  host '127.0.0.1'
  privileges [:all]
  action :grant
end

