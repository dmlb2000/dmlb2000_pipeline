default['dmlb2000_pipeline']['all_slaves']['quick']['name'] = 'quick'
default['dmlb2000_pipeline']['all_slaves']['quick']['password'] = 'password'
default['dmlb2000_pipeline']['all_slaves']['kitchen']['name'] = 'kitchen'
default['dmlb2000_pipeline']['all_slaves']['kitchen']['password'] = 'password'
default['dmlb2000_pipeline']['my_slaves'] = %w( quick kitchen )
default['dmlb2000_pipeline']['master'] = '127.0.0.1'
default['dmlb2000_pipeline']['protocols']['port'] = '8192'
default['dmlb2000_pipeline']['port'] = '8080'
default['dmlb2000_pipeline']['url'] = \
  "http://#{node['ipaddress']}:#{node['dmlb2000_pipeline']['port']}/"

default['dmlb2000_pipeline']['cookbooks'] = %w(
  dmlb2000_pipeline
  dmlb2000_chef
  dmlb2000_distro
  dmlb2000_users
  dmlb2000_server
)

default['vagrant']['user'] = 'buildbot'
default['dmlb2000_pipeline']['libvirt']['users'] = %w(
  dmlb2000
  buildbot
)

default['java']['jdk_version'] = '8'
default['gerrit']['home'] = '/var/lib/gerrit'
default['gerrit']['user'] = 'root'
default['gerrit']['gerrit_args'] = 'daemon'
default['gerrit']['config']['gerrit']['basePath'] = 'git'
default['gerrit']['config']['gerrit']\
       ['canonicalWebUrl'] = "http://#{node['ipaddress']}:8000/"
default['gerrit']['config']['database']['type'] = 'mysql'
default['gerrit']['config']['database']['hostname'] = 'localhost'
default['gerrit']['config']['database']['database'] = 'gerrit'
default['gerrit']['config']['database']['username'] = 'gerrit'
default['gerrit']['config']['index']['type'] = 'LUCENE'
default['gerrit']['config']['auth']['type'] = 'OPENID'
default['gerrit']['config']['sendemail']['smtpServer'] = 'localhost'
default['gerrit']['config']['container']['user'] = 'root'
default['gerrit']['config']['container']\
       ['javaHome'] = node['java']['java_home']
default['gerrit']['config']['sshd']['listenAddress'] = '*:29418'
default['gerrit']['config']['httpd']['listenUrl'] = 'http://*:8000/'
default['gerrit']['config']['cache']['directory'] = 'cache'
default['gerrit']['config']['database']['type'] = 'mysql'
default['gerrit']['config']['database']['database'] = 'gerrit'
default['gerrit']['config']['database']['username'] = 'gerrit'
default['gerrit']['config']['database']['hostname'] = 'localhost'
