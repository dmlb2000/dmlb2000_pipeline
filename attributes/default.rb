default['gerrit']['config']['gerrit']['basePath'] = 'git'
default['gerrit']['config']['gerrit']['canonicalWebUrl'] = "http://#{node['ipaddress']}:8080/"
default['gerrit']['config']['database']['type'] = 'mysql'
default['gerrit']['config']['database']['hostname'] = 'localhost'
default['gerrit']['config']['database']['database'] = 'gerrit'
default['gerrit']['config']['database']['username'] = 'gerrit'
default['gerrit']['config']['index']['type'] = 'LUCENE'
default['gerrit']['config']['auth']['type'] = 'OAUTH'
#default['gerrit']['config']['auth']['httpHeader'] = 'GITHUB_USER'
#default['gerrit']['config']['auth']['logoutUrl'] = '/oauth/reset'
#default['gerrit']['config']['auth']['httpExternalIdHeader'] = 'GITHUB_OAUTH_TOKEN'
#default['gerrit']['config']['auth']['loginUrl'] = '/login'
#default['gerrit']['config']['auth']['loginText'] = 'Sign-in with GitHub'
#default['gerrit']['config']['auth']['registerPageUrl'] = '/#/register'
default['gerrit']['config']['sendemail']['smtpServer'] = 'localhost'
default['gerrit']['config']['container']['user'] = 'root'
default['gerrit']['config']['container']['javaHome'] = '/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.65-2.b17.el7_1.x86_64/jre'
default['gerrit']['config']['sshd']['listenAddress'] = '*:29418'
default['gerrit']['config']['httpd']['listenUrl'] = 'http://*:8080/'
default['gerrit']['config']['cache']['directory'] = 'cache'
default['gerrit']['config']['database']['type'] = 'mysql'
default['gerrit']['config']['database']['database'] = 'gerrit'
default['gerrit']['config']['database']['username'] = 'gerrit'
default['gerrit']['config']['database']['hostname'] = 'localhost'
default['gerrit']['config']['plugin "gerrit-oauth-provider-google-oauth"']['link-to-existing-openid-accounts'] = 'true'
default['gerrit']['config']['plugin "gerrit-oauth-provider-google-oauth"']['client-id'] = '534685879938-1f7o1nsuev7a3v3srir7k9ee2bj0olhj.apps.googleusercontent.com'
default['gerrit']['config']['plugin "gerrit-oauth-provider-github-oauth"']['client-id'] = '60bc131c840c2107799b'

default['java']['jdk_version'] = '8'

default['jenkins']['master']['home'] = '/var/lib/jenkins'
default['jenkins']['master']['listen_address'] = node['ipaddress']
default['jenkins']['master']['jenkins_args'] = '--ajp13Port=8009'
default['jenkins']['master']['port'] = '8081'
default['jenkins']['master']['jvm_options'] = ''
default['jenkins']['master']['user'] = 'root'

default['gerrit']['home'] = '/var/lib/gerrit'
default['gerrit']['user'] = 'root'
default['gerrit']['gerrit_args'] = 'daemon'