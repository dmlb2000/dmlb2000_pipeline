#
# Cookbook Name:: dmlb2000_pipeline
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'chef-dk'
include_recipe 'git'

%W(
dmlb2000_chefbits
).each do |repo|
  git "#{Chef::Config[:file_cache_path]}/#{repo}" do
    repository "https://github.com/dmlb2000/#{repo}"
    action :sync
    notifies :run, "bash[foodcritic-#{repo}]"
  end
  bash "foodcritic-#{repo}" do
    code <<-EOH
      pushd #{Chef::Config[:file_cache_path]}/#{repo}
      foodcritic . -f correctness
      popd
    EOH
    action :nothing
  end
end
