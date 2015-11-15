include_recipe 'java'
directory "/var/lib/jenkins"

remote_file "/var/lib/jenkins/jenkins.war" do
  use_conditional_get true
  source "http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war"
end

template "systemd_jenkins" do
  source "jenkins.systemd.erb"
  path "/lib/systemd/system/jenkins.service"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[systemd-reload]", :immediately
  notifies :restart, "service[jenkins]"
end

execute "systemd-reload" do
  action :nothing
  command "/bin/systemctl daemon-reload"
end

service "jenkins" do
  action [ :enable, :start ]
end

jenkins_cli = '/var/lib/jenkins/jenkins-cli.jar'
remote_file jenkins_cli do
  source "http://#{node['ipaddress']}:#{node['jenkins']['master']['port']}/jnlpJars/jenkins-cli.jar"
  notifies :run, "execute[update-plugins]"
end

jenkins_cmd = "java -jar #{jenkins_cli} -s http://#{node['ipaddress']}:#{node['jenkins']['master']['port']}"

execute "update-plugins" do
  command "#{jenkins_cmd} list-plugins | grep ')$' | awk '{ print $1 }' | xargs -r #{jenkins_cmd} install-plugin"
  only_if { File.exists?(jenkins_cli) }
  notifies :run, 'execute[restart-jenkins]'
  action :nothing
end

execute 'restart-jenkins' do
  command "#{jenkins_cmd} restart"
  action :nothing
  only_if { File.exists?(jenkins_cli) }
end

include_recipe 'dmlb2000_pipeline::jenkinsplugins'

