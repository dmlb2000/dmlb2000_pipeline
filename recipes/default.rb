#
# Cookbook Name:: dmlb2000_pipeline
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'yum-centos'
include_recipe 'yum-epel'
include_recipe 'git'

package 'python-pip'
package 'python-virtualenv'

user 'buildbot' do
  home '/var/lib/buildbot'
end

include_recipe 'dmlb2000_chef'

%w(
  /var/lib/buildbot/virtualenv
  /var/lib/buildbot/master
  /var/lib/buildbot/slave
).each do |buildbot_dir|
  directory buildbot_dir do
    owner 'buildbot'
    group 'buildbot'
  end
end

python_virtualenv '/var/lib/buildbot/virtualenv' do
  owner 'buildbot'
  group 'buildbot'
  action :create
end

python_pip 'buildbot' do
  virtualenv '/var/lib/buildbot/virtualenv'
end

python_pip 'buildbot-slave' do
  virtualenv '/var/lib/buildbot/virtualenv'
end
