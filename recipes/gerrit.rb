include_recipe 'dmlb2000_pipeline::database'
include_recipe 'java'

if Chef::Config[:solo]
  pwd = {
    gerrit_secure: {
      database: {
        password: 'gerrit'
      }
    }
  }
else
  chef_gem 'chef-vault'
  require 'chef-vault'
  pwd = chef_vault_item('pipeline', 'secrets').to_hash
end

directory '/var/lib/gerrit'
directory '/var/lib/gerrit/data'
directory '/var/lib/gerrit/data/plugins'
directory '/var/lib/gerrit/data/etc'

remote_file '/var/lib/gerrit/gerrit.war' do
  use_conditional_get true
  source 'https://www.gerritcodereview.com/download/gerrit-2.11.4.war'
end

template 'gerrit_config' do
  source 'inidata.erb'
  path "#{node['gerrit']['home']}/data/etc/gerrit.config"
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[gerrit]'
  variables(
    data: node['gerrit']['config']
  )
end

template 'gerrit_secure' do
  source 'inidata.erb'
  path "#{node['gerrit']['home']}/data/etc/secure.config"
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[gerrit]'
  variables(
    data: pwd[:gerrit_secure]
  )
end

execute 'gerrit-init' do
  cwd "#{node['gerrit']['home']}/data"
  command "java -jar #{node['gerrit']['home']}/gerrit.war init --batch"
  not_if { File.directory?("#{node['gerrit']['home']}/data/db") }
end
execute 'gerrit-reindex' do
  cwd "#{node['gerrit']['home']}/data"
  command "java -jar #{node['gerrit']['home']}/gerrit.war reindex"
  not_if { File.directory?("#{node['gerrit']['home']}/data/index") }
end

systemd_service 'gerrit' do
  description 'gerrit daemon'
  after %w( network.target )
  install do
    wanted_by 'multi-user.target'
  end
  service do
    user node['gerrit']['user']
    standard_output 'syslog'
    standard_error 'syslog'
    working_directory "#{node['gerrit']['home']}/data"
    exec_start "/etc/alternatives/java #{node['gerrit']['jvm_options']} "\
               "-jar #{node['gerrit']['home']}/gerrit.war "\
               "#{node['gerrit']['gerrit_args']}"
  end
end

service 'gerrit' do
  action [:enable, :start]
end
