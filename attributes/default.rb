default['dmlb2000_buildbot']['slaves']['example-slave'] = 'password'
default['dmlb2000_buildbot']['slave']['name'] = 'example-slave'
default['dmlb2000_buildbot']['slave']['password'] = 'password'
default['dmlb2000_buildbot']['master'] = '127.0.0.1'
default['dmlb2000_buildbot']['protocols']['port'] = '8192'
default['dmlb2000_buildbot']['port'] = '8080'
default['dmlb2000_buildbot']['url'] = "http://#{node['ipaddress']}:#{node['dmlb2000_buildbot']['port']}/"
