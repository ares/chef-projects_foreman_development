install_path = project_path('smart-proxy')

github_project 'smart-proxy' do
  path install_path
  project_owner node[:user]
  user node[:user]
  branch 'develop'
end

# puppet setup (plus it's yaml config below)
directory "/etc/puppet" do
  owner node[:user]
  group node[:user]
  mode '0755'
end

directory "/etc/puppet/code/environments/production/modules" do
  owner node[:user]
  group node[:user]
  mode '0755'
  recursive true
end

directory "/etc/puppet/code" do
  owner node[:user]
  group node[:user]
  mode '0755'
  recursive true
end

template '/etc/puppet/puppet.conf' do
  owner node[:user]
  group node[:user]
  mode '0644'
  source 'smart_proxy/puppet.conf.erb'
end

directory '/var/lib/puppet' do
  owner node[:user]
  group node[:user]
  mode '0755'
end

directory '/var/lib/puppet/run' do
  owner node[:user]
  group node[:user]
  mode '0755'
end

cookbook_file '/etc/puppet/node.rb' do
  owner node[:user]
  group node[:user]
  mode '0755'
  source 'smart_proxy/external_node_v2.rb'
end

cookbook_file '/etc/puppet/foreman.rb' do
  owner node[:user]
  group node[:user]
  mode '0755'
  source 'smart_proxy/foreman-report_v2.rb'
end

template '/etc/puppet/foreman.yaml' do
  owner node[:user]
  group node[:user]
  mode '0644'
  source 'smart_proxy/foreman.yaml'
end

link '/var/lib/puppet/ssl' do
  to '/etc/puppet/ssl'
end

%w(puppet puppetca).each do |config|
  template "#{install_path}/config/settings.d/#{config}.yml" do
    source "smart_proxy/#{config}.yml.example"
    owner node[:user]
    group node[:user]
    mode '0644'
  end
end
# end of puppet

## config files start
template "#{install_path}/config/settings.yml" do
  source 'smart_proxy/settings.yml.erb'
  owner node[:user]
  group node[:user]
  mode '0644'
  # TODO should use own foreman_url based on foreman's foreman_fqdn otherwise won't be usable standalone
  #   if we'd trust puppet CA globally maybe it would work even without
  variables :foreman_ca_path => ca_install_path('ares_ca.pem'), :foreman_url => "https://#{node[:projects][:foreman][:foreman_fqdn]}"
end

%w(bmc dhcp_virsh dhcp dns_virsh dns tftp).each do |config|
  template "#{install_path}/config/settings.d/#{config}.yml" do
    source "smart_proxy/#{config}.yml.example"
    owner node[:user]
    group node[:user]
    mode '0644'
  end
end
## config files end

template "#{install_path}/bundler.d/Gemfile.chef.local.rb" do
  source 'smart_proxy/Gemfile.chef.local.rb.erb'
  mode '0644'
  owner node[:user]
  group node[:user]
end

# augeas gem has some native extensions
package 'augeas-devel'

# plugins
node[:projects][:smart_proxy][:plugins].each do |name, plugin_attributes|
  smart_proxy_plugin name do
    plugin plugin_attributes
    main_project_path install_path
  end
end
# plugins end

bundle_install install_path do
  user node[:user]
end
