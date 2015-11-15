include_recipe 'dmlb2000_pipeline::database'
include_recipe 'java'

if Chef::Config[:solo]
  pwd = {
    "gerrit_secure" => {
      "database" => {
        "password" => "gerrit"
      },
      "auth" => {
        "registerEmailPrivateKey" => "Uatl59nrLm4ZiD7kHd99HW7WZt94V67lU58=",
        "restTokenPrivateKey" => "sDR69mWCtN9SrQi4a7ffa+VagZlg5WqdpMo="
      },
      'plugin "gerrit-oauth-provider-google-oauth"' => {
        "client-secret" => 'Zg7iK8ps3_LEcGXBfaF_f6tC'
      },
      'plugin "gerrit-oauth-provider-github-oauth"' => {
        "client-secret" => '0163977b3073569096ca125cb40778982414db0b'
      }
    }
  }
else
  chef_gem 'chef-vault'
  require 'chef-vault'
  pwd = chef_vault_item('pipeline', 'secrets').to_hash()
end

directory "/var/lib/gerrit"
directory "/var/lib/gerrit/data"
directory "/var/lib/gerrit/data/plugins"
directory "/var/lib/gerrit/data/etc"

include_recipe 'dmlb2000_pipeline::gerritplugins'

remote_file "/var/lib/gerrit/gerrit.war" do
  use_conditional_get true
  source "https://www.gerritcodereview.com/download/gerrit-2.11.4.war"
end

template "gerrit_config" do
  source "inidata.erb"
  path "#{node['gerrit']['home']}/data/etc/gerrit.config"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[gerrit]"
  variables({
    :data => node['gerrit']['config']
  })
end

template "gerrit_secure" do
  source "inidata.erb"
  path "#{node['gerrit']['home']}/data/etc/secure.config"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[gerrit]"
  variables({
    :data => pwd['gerrit_secure']
  })
end

execute "gerrit-init" do
  cwd "#{node['gerrit']['home']}/data"
  command "java -jar #{node['gerrit']['home']}/gerrit.war init --batch"
  not_if { File.directory?("#{node['gerrit']['home']}/data/db") }
end
execute "gerrit-reindex" do
  cwd "#{node['gerrit']['home']}/data"
  command "java -jar #{node['gerrit']['home']}/gerrit.war reindex"
  not_if { File.directory?("#{node['gerrit']['home']}/data/index") }
end

template "systemd_gerrit" do
  source "gerrit.systemd.erb"
  path "/lib/systemd/system/gerrit.service"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[systemd-reload]", :immediately
  notifies :restart, "service[gerrit]"
end

execute "systemd-reload" do
  action :nothing
  command "/bin/systemctl daemon-reload"
end

service "gerrit" do
  action [ :enable, :start ]
end

