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
    knife upload environments
    knife upload roles
    knife upload data bags
  EOH
  action :nothing
end

require 'date'
datestring = DateTime.now.to_s

%w(
  dmlb2000_distro
  dmlb2000_chef
).each do |repo|
  repodir = "#{Chef::Config[:file_cache_path]}/#{repo}"
  logdir = "#{Chef::Config[:file_cache_path]}/#{repo}-logs"
  git repodir do
    repository "https://github.com/dmlb2000/#{repo}.git"
    action :sync
    notifies :run, "bash[#{repo}-checkit]", :immediately
  end
  directory logdir
  bash "#{repo}-checkit" do
    cwd repodir
    code <<-EOH
(
  set -xe
  foodcritic . -f correctness
  rubocop
  berks install
  kitchen test
) > #{logdir}/#{datestring}.log 2>&1
rc=$?
kitchen destroy
if [[ $rc == 0 ]] ; then
  echo Success > #{logdir}/#{datestring}.success
else
  echo Failure > #{logdir}/#{datestring}.failure
fi
    EOH
    action :nothing
  end
  bash "#{repo}-failure" do
    cwd logdir
    code <<-EOH
mail -s "[chef-pipeline] #{repo} failed" \
     -a #{datestring}.log \
     -r "dmlb2000@dmlb2000.org" \
     "dmlb2000@gmail.com" <<EOF
Chef pipeline failed to run, check logs attached.
EOF
    EOH
    only_if { ::File.exist?("#{logdir}/#{datestring}.failure") }
  end
  bash "#{repo}-success" do
    cwd logdir
    code <<-EOH
mail -s "[chef-pipeline] #{repo} success" \
     -a #{datestring}.log \
     -r "dmlb2000@dmlb2000.org" \
     "dmlb2000@gmail.com" <<EOF
Chef pipeline succeded and was uploaded.
EOF
    EOH
    only_if { ::File.exist?("#{logdir}/#{datestring}.success") }
    notifies :run, "bash[#{repo}-upload]"
  end
end

repo = 'dmlb2000_pipeline'
repodir = "#{Chef::Config[:file_cache_path]}/#{repo}"
logdir = "#{Chef::Config[:file_cache_path]}/#{repo}-logs"

git repodir do
  repository "https://github.com/dmlb2000/#{repo}.git"
  action :sync
  notifies :run, "bash[#{repo}-checkit]", :immediately
end

directory logdir
bash "#{repo}-checkit" do
  cwd repodir
  code <<-EOH
(
  set -xe
  foodcritic . -f correctness
  rubocop
  berks install
) > #{logdir}/#{datestring}.log 2>&1
rc=$?
if [[ $rc == 0 ]] ; then
  echo Success > #{logdir}/#{datestring}.success
else
  echo Failure > #{logdir}/#{datestring}.failure
fi
  EOH
  action :nothing
end
bash "#{repo}-failure" do
  cwd logdir
  code <<-EOH
mail -s "[chef-pipeline] #{repo} failed" \
     -a #{datestring}.log \
     -r "dmlb2000@dmlb2000.org" \
     "dmlb2000@gmail.com" <<EOF
Chef pipeline failed to run, check logs attached.
EOF
  EOH
  only_if { ::File.exist?("#{logdir}/#{datestring}.failure") }
end
bash "#{repo}-success" do
  cwd logdir
  code <<-EOH
mail -s "[chef-pipeline] #{repo} success" \
     -a #{datestring}.log \
     -r "dmlb2000@dmlb2000.org" \
     "dmlb2000@gmail.com" <<EOF
Chef pipeline succeded and was uploaded.
EOF
  EOH
  only_if { ::File.exist?("#{logdir}/#{datestring}.success") }
  notifies :run, "bash[#{repo}-upload]"
end

%w(
  dmlb2000_distro
  dmlb2000_chef
  dmlb2000_pipeline
).each do |repo2|
  bash "#{repo2}-upload" do
    cwd "#{Chef::Config[:file_cache_path]}/chef-repo"
    code <<-EOH
set -xe
berks install
berks upload #{repo2}
    EOH
    action :nothing
  end
end
