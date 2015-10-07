#
# Cookbook Name:: dmlb2000_pipeline
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'git'

git "#{Chef::Config[:file_cache_path]}/chef-repo" do
  repository "https://github.com/dmlb2000/chef-repo.git"
  action :sync
  notifies :run, 'bash[chef-repo-check]'
end

bash 'chef-repo-check' do
  cwd "#{Chef::Config[:file_cache_path]}/chef-repo"
  code <<-EOH
    set -xe
    berks install
    berks upload
    knife upload environments
    knife upload roles
    knife upload data bags
  EOH
  action :nothing
end

%w(
dmlb2000_distro
dmlb2000_chefbits
).each do |repo|
  git "#{Chef::Config[:file_cache_path]}/#{repo}" do
    repository "https://github.com/dmlb2000/#{repo}.git"
    action :sync
    notifies :run, "bash[#{repo}-checkit]"
  end
  bash "#{repo}-checkit" do
    cwd "#{Chef::Config[:file_cache_path]}/#{repo}"
    code <<-EOH
      set -xe
      foodcritic . -f correctness
    EOH
  end
end
