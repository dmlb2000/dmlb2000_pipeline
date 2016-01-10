include_recipe 'dmlb2000_pipeline::default'

node['dmlb2000_pipeline']['my_slaves'].each do |slave|
  directory "/var/lib/buildbot/slave/#{slave}" do
    owner 'buildbot'
    group 'buildbot'
  end

  master_ip = node['dmlb2000_pipeline']['master']
  master_port = node['dmlb2000_pipeline']['protocols']['port']

  bash "build-slave-#{slave}" do
    cwd "/var/lib/buildbot/slave/#{slave}"
    code <<-EOH
source /var/lib/buildbot/virtualenv/bin/activate
buildslave create-slave . \
    #{master_ip}:#{master_port} \
    #{node['dmlb2000_pipeline']['all_slaves'][slave]['name']} \
    #{node['dmlb2000_pipeline']['all_slaves'][slave]['password']}
EOH
    user 'buildbot'
    not_if { File.exist?("/var/lib/buildbot/slave/#{slave}/buildbot.tac") }
  end

  systemd_service "buildbot-slave-#{slave}" do
    description 'buildbot slave daemon'
    after %w( network.target )
    install do
      wanted_by 'multi-user.target'
    end
    service do
      user 'buildbot'
      working_directory "/var/lib/buildbot/slave/#{slave}"
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
      exec_start '/var/lib/buildbot/virtualenv/bin/buildslave start --nodaemon'
    end
  end

  service "buildbot-slave-#{slave}" do
    action [:enable, :start]
  end
end
