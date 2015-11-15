package 'docker'
service 'docker' do
  action [:enable, :start]
end

docker_image 'dmlb2000/docker-gerrit'
docker_image 'dmlb2000/docker-postfix'
docker_image 'mysql'
docker_image 'jenkins'

user "pipeline" do
  uid 1234
end

directory "/var/lib/mysql" do
  owner 999
  group 999
end
directory "/var/lib/gerrit"
directory "/var/lib/gerrit/jenkins" do
  owner "pipeline"
end
directory "/var/lib/gerrit/data" do
  owner "pipeline"
end

directory "/var/lib/gerrit/data/plugins" do
  owner "pipeline"
end

directory "/var/lib/gerrit/data/etc" do
  owner "pipeline"
end

template "/var/lib/gerrit/data/etc/gerrit.config" do
  source 'inidata.erb'
  variables({
    :data => node['gerrit']['config']
  })
end
template "/var/lib/gerrit/data/etc/secure.config" do
  source 'inidata.erb'
  variables({
    :data => node['gerrit']['secure']
  })
end

docker_container "gerrit-mysql" do
  image 'mysql'
  env [
    'MYSQL_ROOT_PASSWORD=password',
    'MYSQL_DATABASE=gerrit',
    'MYSQL_USER=gerrit',
    'MYSQL_PASSWORD=gerrit'
  ]
  binds [ '/var/lib/mysql:/var/lib/mysql' ]
end

docker_container 'gerrit-postfix' do
  image 'dmlb2000/docker-postfix'
  env [
    'maildomain=mail.dmlb2000.org',
    'smtp_user=gerrit:gerrit'
  ]
end

docker_container 'gerrit' do
  image 'dmlb2000/docker-gerrit'
  user '1234'
  binds [ '/var/lib/gerrit/data:/data' ]
  port [ '8080:8080', '29418:29418' ]
  links [ 'gerrit-mysql:mysql', 'gerrit-postfix:mail' ]
  env [ "GERRIT_ADDR=#{node['ipaddress']}", "GERRIT_PLUGINS=https://gerrit-ci.gerritforge.com/job/plugin-github-mvn-stable-2.11/lastSuccessfulBuild/artifact/github-oauth/target/github-oauth-2.11.jar https://gerrit-ci.gerritforge.com/job/plugin-github-mvn-stable-2.11/lastSuccessfulBuild/artifact/github-plugin/target/github-plugin-2.11.jar" ]
end

docker_container 'gerrit-jenkins' do
  image 'jenkins'
  user '1234'
  port [ '8000:8080', '50000:50000' ]
  binds [ '/var/lib/gerrit/jenkins:/var/jenkins_home' ]
  links [ 'gerrit:gerrit' ]
end

jenkins_cli_chk = 'docker exec gerrit-jenkins test -e /tmp/jenkins-cli.jar'

execute 'get_jenkins_cli' do
  command 'docker exec gerrit-jenkins curl http://localhost:8080/jnlpJars/jenkins-cli.jar -o /tmp/jenkins-cli.jar'
  not_if jenkins_cli_chk
  ignore_failure true
end

jenkins_cli_cmd = 'docker exec gerrit-jenkins java -jar /tmp/jenkins-cli.jar -s http://localhost:8080'

execute 'restart_jenkins' do
  command "#{jenkins_cli_cmd} restart"
  action :nothing
  only_if jenkins_cli_chk
end

execute 'update_plugins' do
  command "#{jenkins_cli_cmd} list-plugins | grep ')$' | awk '{ print $1 }' | xargs -r #{jenkins_cli_cmd} install-plugin"
  notifies :run, 'execute[restart_jenkins]'
  subscribes :run, 'execute[get_jenkins_cli]'
  only_if jenkins_cli_chk
end

%w(
gerrit
gerrit-trigger
git
).each do |plugin|
  execute "install_#{plugin}" do
    command "#{jenkins_cli_cmd} install-plugin #{plugin}"
    only_if jenkins_cli_chk
    not_if "test -d /var/lib/gerrit/jenkins/plugins/#{plugin}"
    notifies :run, 'execute[restart_jenkins]'
  end
end
