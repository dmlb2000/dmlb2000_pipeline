default['dmlb2000_pipeline']['all_slaves']['quick']['name'] = 'quick'
default['dmlb2000_pipeline']['all_slaves']['quick']['password'] = 'password'
default['dmlb2000_pipeline']['all_slaves']['kitchen']['name'] = 'kitchen'
default['dmlb2000_pipeline']['all_slaves']['kitchen']['password'] = 'password'
default['dmlb2000_pipeline']['my_slaves'] = %w( quick kitchen )
default['dmlb2000_pipeline']['master'] = '127.0.0.1'
default['dmlb2000_pipeline']['protocols']['port'] = '8192'
default['dmlb2000_pipeline']['port'] = '8080'
default['dmlb2000_pipeline']['webhook_port'] = '8081'
default['dmlb2000_pipeline']['url'] = \
  "http://#{node['ipaddress']}:#{node['dmlb2000_pipeline']['port']}/"

default['dmlb2000_pipeline']['cookbooks'] = %w(
  dmlb2000_pipeline
  dmlb2000_chef
  dmlb2000_chefdk
  dmlb2000_distro
  dmlb2000_users
  dmlb2000_server
  dmlb2000_desktop
)

default['vagrant']['user'] = 'buildbot'
default['dmlb2000_pipeline']['libvirt']['users'] = %w(
  dmlb2000
  buildbot
)
