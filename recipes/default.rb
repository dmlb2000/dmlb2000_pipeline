#
# Cookbook Name:: dmlb2000_pipeline
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'git'

git "#{Chef::Config[:file_cache_path]}/chef-repo" do
  repository 'https://github.com/dmlb2000/chef-repo.git'
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

require 'date'
datestring = DateTime.now().to_s

%w(
  dmlb2000_distro
  dmlb2000_chefbits
).each do |repo|
  git "#{Chef::Config[:file_cache_path]}/#{repo}" do
    repository "https://github.com/dmlb2000/#{repo}.git"
    action :sync
    notifies :run, "bash[#{repo}-checkit]", :immediately
  end
  directory "#{Chef::Config[:file_cache_path]}/#{repo}-logs"
  bash "#{repo}-checkit" do
    cwd "#{Chef::Config[:file_cache_path]}/#{repo}"
    code <<-EOH
      (
      set -xe
      foodcritic . -f correctness
      rubocop
      kitchen test
      ) > #{Chef::Config[:file_cache_path]}/#{repo}-logs/#{datestring}.log 2>&1
      rc=$?
      kitchen destroy
      if [[ $rc != 0 ]] ; then
        echo Success > #{Chef::Config[:file_cache_path]}/#{repo}-logs/#{datestring}.success
      else
        echo Failure > #{Chef::Config[:file_cache_path]}/#{repo}-logs/#{datestring}.failure
      fi
    EOH
    action :nothing
  end
  bash "#{repo}-failure" do
    cwd "#{Chef::Config[:file_cache_path]}/#{repo}-logs"
    code <<-EOH
      mail -s "[chef-pipeline] #{repo} failed" -a #{datestring}.log -r "dmlb2000@dmlb2000.org" <<EOF
      Chef pipeline failed to run, check logs attached.
      EOF
    EOH
    only_if do ::File.exists?("#{Chef::Config[:file_cache_path]}/#{repo}-logs/#{datestring}.failure") end
  end
  bash "#{repo}-success" do
    cwd "#{Chef::Config[:file_cache_path]}/#{repo}-logs"
    code <<-EOH
      mail -s "[chef-pipeline] #{repo} success" -a #{datestring}.log -r "dmlb2000@dmlb2000.org" <<EOF
      Chef pipeline succeded and was uploaded.
      EOF
    EOH
    only_if do ::File.exists?("#{Chef::Config[:file_cache_path]}/#{repo}-logs/#{datestring}.success") end
    notifies :run, "bash[#{repo}-upload]"
  end
end

git "#{Chef::Config[:file_cache_path]}/dmlb2000_pipeline" do
  repository 'https://github.com/dmlb2000/dmlb2000_pipeline.git'
  action :sync
  notifies :run, 'bash[pipeline-checkit]', :immediately
end

directory "#{Chef::Config[:file_cache_path]}/dmlb2000_pipeline-logs"
bash 'pipeline-checkit' do
  cwd "#{Chef::Config[:file_cache_path]}/dmlb2000_pipeline"
  code <<-EOH
    (
    set -xe
    foodcritic . -f correctness
    rubocop
    ) > #{Chef::Config[:file_cache_path]}/dmlb2000_pipeline-logs/#{datestring}.log 2>&1
    rc=$?
    if [[ $rc != 0 ]] ; then
      echo Success > #{Chef::Config[:file_cache_path]}/dmlb2000_pipeline-logs/#{datestring}.success
    else
      echo Failure > #{Chef::Config[:file_cache_path]}/dmlb2000_pipeline-logs/#{datestring}.failure
    fi
  EOH
  action :nothing
end
repo = "dmlb2000_pipeline"
bash "#{repo}-failure" do
  cwd "#{Chef::Config[:file_cache_path]}/#{repo}-logs"
  code <<-EOH
    mail -s "[chef-pipeline] #{repo} failed" -a #{datestring}.log -r "dmlb2000@dmlb2000.org" <<EOF
    Chef pipeline failed to run, check logs attached.
    EOF
  EOH
  only_if do ::File.exists?("#{Chef::Config[:file_cache_path]}/#{repo}-logs/#{datestring}.failure") end
end
bash "#{repo}-success" do
  cwd "#{Chef::Config[:file_cache_path]}/#{repo}-logs"
  code <<-EOH
    mail -s "[chef-pipeline] #{repo} success" -a #{datestring}.log -r "dmlb2000@dmlb2000.org" <<EOF
    Chef pipeline succeded and was uploaded.
    EOF
  EOH
  only_if do ::File.exists?("#{Chef::Config[:file_cache_path]}/#{repo}-logs/#{datestring}.success") end
  notifies :run, "bash[#{repo}-upload]"
end

%w(
  dmlb2000_distro
  dmlb2000_chefbits
  dmlb2000_pipeline
).each do |repo|
  bash "#{repo}-upload" do
    cwd "#{Chef::Config[:file_cache_path]}/#{repo}"
    code <<-EOH
      set -xe
      berks upload
    EOH
    action :nothing
  end
end
