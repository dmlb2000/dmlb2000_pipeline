include_recipe 'dmlb2000_pipeline::default'

bash 'build_master' do
  cwd '/var/lib/buildbot/master'
  code <<-EOH
source /var/lib/buildbot/virtualenv/bin/activate
buildbot create-master .
EOH
  user 'buildbot'
  not_if { File.exist?('/var/lib/buildbot/master/buildbot.tac') }
end

template '/var/lib/buildbot/master/master.cfg' do
  notifies :restart, 'service[buildbot]'
end

systemd_service 'buildbot' do
  description 'buildbot daemon'
  after %w( network.target )
  install do
    wanted_by 'multi-user.target'
  end
  service do
    user 'buildbot'
    working_directory '/var/lib/buildbot/master'
    environment VIRTUAL_ENV: '/var/lib/buildbot/virtualenv',
                PATH: %w(
                  /var/lib/buildbot/virtualenv/bin
                  /usr/local/sbin
                  /usr/local/bin
                  /sbin
                  /bin
                  /usr/sbin
                  /usr/bin
                ).join(':')
    exec_start '/var/lib/buildbot/virtualenv/bin/buildbot start --nodaemon'
  end
end

service 'buildbot' do
  action [:enable, :start]
end

cookbook_file '/var/lib/buildbot/kitchen_run.sh' do
  mode '0755'
end
