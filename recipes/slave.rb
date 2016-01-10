include_recipe 'dmlb2000_buildbot::default'

bash "build_slave" do
  cwd '/var/lib/buildbot/slave'
  code <<-EOH
source /var/lib/buildbot/virtualenv/bin/activate
buildslave create-slave . \
    #{node['dmlb2000_buildbot']['master']}:#{node['dmlb2000_buildbot']['protocols']['port']} \
    #{node['dmlb2000_buildbot']['slave']['name']} \
    #{node['dmlb2000_buildbot']['slave']['password']}
EOH
  user 'buildbot'
  not_if { File.exists?('/var/lib/buildbot/slave/buildbot.tac') }
end

systemd_service 'buildbot-slave' do
  description 'buildbot slave daemon'
  after %w( network.target )
  install do
    wanted_by 'multi-user.target'
  end
  service do
    user 'buildbot'
    working_directory '/var/lib/buildbot/slave'
    environment VIRTUAL_ENV: '/var/lib/buildbot/virtualenv',
                PATH: '/var/lib/buildbot/virtualenv/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
    exec_start "/var/lib/buildbot/virtualenv/bin/buildslave start --nodaemon"
  end
end

service 'buildbot-slave' do
  action [:enable, :start]
end
