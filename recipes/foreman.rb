install_path = project_path('foreman')

github_project 'foreman' do
  path install_path
  project_owner node[:user]
  user node[:user]
  branch 'develop'
end

## config files start
template "#{install_path}/config/database.yml" do
  owner node[:user]
  group node[:user]
  mode '0644'
  source 'foreman/database.yml.erb'
end

template "#{install_path}/config/settings.yaml" do
  source 'foreman/settings.yaml.erb'
  owner node[:user]
  group node[:user]
  mode '0644'
end
# config files end

## DB start
include_recipe 'projects::setup_postgres'
postgresql_connection_info = { :host => "127.0.0.1",
                               :port => node['postgresql']['config']['port'],
                               :username => 'postgres',
                               :password => node['postgresql']['password']['postgres'] }

postgresql_database_user 'foreman' do
  connection postgresql_connection_info
  password node[:projects][:foreman][:password]
  privileges [:all] # probably not needed
  createdb true
  action :create
end

%w(foreman foreman_testing).each do |db|
  postgresql_database db do
    connection postgresql_connection_info
    action :create
    owner 'foreman'
  end
end

case node[:platform]
  when 'debian', 'ubuntu'
    package 'libsqlite3-dev'
    package 'libmysqlclient-dev'
  when 'redhat', 'centos', 'fedora'
    package 'sqlite-devel'
    if node.platform?('rhel', 'centos') && node[:platform_version].to_i > 6
      package 'mariadb-devel'
    else
      package 'mysql-devel'
    end
end

# TODO mysql and make the whole recipe configurable so it can be reused on devel_host
## DB end

template "#{install_path}/bundler.d/Gemfile.chef.local.rb" do
  source 'foreman/Gemfile.chef.local.rb.erb'
  mode '0644'
  owner node[:user]
  group node[:user]
end

## plugins install
node[:projects][:foreman][:plugins].each do |name, plugin_attributes|
  bundled_plugin name do
    plugin plugin_attributes
    main_project_path install_path
  end
end
## plugins end

bundle_install install_path do
  user node[:user]
end

rake_db_migrate install_path do
  user node[:user]
end

rake_db_seed install_path do
  user node[:user]
  env({ :SEED_ADMIN_PASSWORD => node[:projects][:foreman][:password] })
end

if node[:projects][:foreman][:setup_libvirt]
  # Libvirt setup
  service 'libvirtd' do
    action :nothing
  end

  include_recipe 'libvirt'

  libvirt_network 'default' do
    gateway '192.168.122.1'
    netmask '255.255.255.0'
    forward 'nat'
    domain 'example.tst'
    bridge 'virbr0'
    tftp true
    dhcp_range :start => '192.168.122.20', :end => '192.168.122.254'
    dns_a_records 'foreman.example.tst' => '192.168.122.1'
    action [:define, :autostart]
  end

  # on EL6 we can't rely on NetworkManager so we skip this
  if !node.platform?('rhel', 'centos') || node[:platform_version].to_i > 6
    # Network manager must be set to use local dnsmasq so we have good control of example.tst domain
    template '/etc/NetworkManager/NetworkManager.conf' do
      source 'foreman/NetworkManager.conf.erb'
      mode '0644'
      notifies :restart, 'service[libvirtd]'
    end
  
    template '/etc/NetworkManager/dnsmasq.d/foreman_libvirt.conf' do
      source 'foreman/foreman_libvirt.conf'
      mode '0644'
      notifies :restart, 'service[libvirtd]'
    end
  end

  # for deb different packages are required - https://github.com/theforeman/puppet-tftp/blob/master/manifests/params.pp
  package 'tftp'
  package 'tftp-server'
  package 'syslinux'

  tftp_dirs = %w(/var/lib/tftpboot/pxelinux.cfg /var/lib/tftpboot/boot)
  tftp_dirs.each do |dir|
    directory dir do
      owner node[:user]
      group node[:user]
      mode '0755'
    end
  end

  if !node.platform?('rhel', 'centos') || node[:platform_version].to_i > 6
    template '/etc/polkit-1/rules.d/60-libvirt.rules' do
      owner node[:user]
      group node[:user]
      mode '0644'
      source 'foreman/libvirt.rules.erb'
      variables :user => node[:user]
    end
  end

  %w(chain.c32 menu.c32 memdisk pxelinux.0 ldlinux.c32 libutil.c32).each do |file|
    link "/var/lib/tftpboot/#{file}" do
      to "/usr/share/syslinux/#{file}"
    end
  end
  # TODO add more subnets (e.g. static, provision) when needed
  # end of libvirt
end

# nginx proxy
ca_cert('ares_ca.pem')
include_recipe 'nginx'

certificate_path = "#{node['nginx']['dir']}/foreman.example.tst.pem"
cookbook_file certificate_path do
  source 'foreman.example.tst.pem'
  owner node['nginx']['user']
  group node['nginx']['group']
  mode '0644'
end

private_key_path = "#{node['nginx']['dir']}/foreman.example.tst.key"
cookbook_file private_key_path do
  source 'foreman.example.tst.key'
  owner node['nginx']['user']
  # smart proxy must be able to read it, using group for sharing
  group node[:user]
  mode '0660'
end

access_log = node['nginx']['log_dir'] + '/foreman-access'
error_log = node['nginx']['log_dir'] + '/foreman-error'
template node['nginx']['dir'] + "/sites-available/foreman.conf" do
  source 'foreman/foreman.conf.erb'
  owner node['nginx']['user']
  group node['nginx']['group']
  variables({
              :certificate_path => certificate_path,
              :private_key_path => private_key_path,
              :ca_path => ca_install_path('ares_ca.pem'),
              :access_log => access_log,
              :error_log => error_log,
            })
  notifies :restart, "service[nginx]"
end

link node['nginx']['dir'] + "/sites-enabled/50-foreman.conf" do
  to node['nginx']['dir'] + "/sites-available/foreman.conf"
end

# end of nginx

if node[:projects][:foreman][:setup_apt_cacher_ng]
  # apt-proxy-ng
  package 'apt-cacher-ng'
  service 'apt-cacher-ng' do
    action  [ :enable, :start ]
  end
  # end of apt-proxy-ng
end

# seed script start
template "#{install_path}/tmp/seed_script.sh" do
  source 'foreman/seed_script.sh.erb'
  mode '0755'
  owner node[:user]
  group node[:user]
end
# seed script end

# TODO setup zeus
# https://github.com/iNecas/katello.org/blob/fe105daf59b80eadc468b82175a81ff152818d06/developers/testing.md
# and foreman proxy settings from edna
