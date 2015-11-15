include_recipe 'java'
include_recipe 'git'
include_recipe 'build-essential'

package "zip"
package "ant"

git "#{Chef::Config[:file_cache_path]}/buck" do
  repository "https://github.com/facebook/buck.git"
  notifies :run, "execute[build-buck]", :immediately
end

git "#{Chef::Config[:file_cache_path]}/gerrit-oauth-provider" do
  repository "https://github.com/davido/gerrit-oauth-provider.git"
  notifies :run, "execute[build-gerrit-oauth-provider]", :immediately
  enable_submodules true
end

execute "build-buck" do
  command "ant && ./bin/buck build buck"
  cwd "#{Chef::Config[:file_cache_path]}/buck"
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/buck/build/report-generator.jar") and ::File.directory?("#{Chef::Config[:file_cache_path]}/buck/buck-out") }
end

execute "build-gerrit-oauth-provider" do
  command "buck build plugin"
  environment 'PATH' => "/sbin:/usr/sbin:/bin:/usr/sbin:#{Chef::Config[:file_cache_path]}/buck/bin"
  cwd "#{Chef::Config[:file_cache_path]}/gerrit-oauth-provider"
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/gerrit-oauth-provider/buck-out/gen/gerrit-oauth-provider.jar") }
end

link "/var/lib/gerrit/data/plugins/gerrit-oauth-provider.jar" do
  to "#{Chef::Config[:file_cache_path]}/gerrit-oauth-provider/buck-out/gen/gerrit-oauth-provider.jar"
end
