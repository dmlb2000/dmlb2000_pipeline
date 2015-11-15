jenkins_cli = '/var/lib/jenkins/jenkins-cli.jar'
jenkins_cmd = "java -jar #{jenkins_cli} -s http://#{node['ipaddress']}:#{node['jenkins']['master']['port']}"
%w(
gerrit
gerrit-trigger
git
).each do |plugin|
  execute "install-#{plugin}" do
    command "#{jenkins_cmd} install-plugin #{plugin}"
    only_if { File.exists?(jenkins_cli) }
    not_if "test -d #{node['jenkins']['master']['home']}/plugins/#{plugin}"
    notifies :run, 'execute[restart-jenkins]'
  end
end

