case node.platform
when 'debian', 'ubuntu'
  package 'libcurl4-openssl-dev'
when 'centos', 'redhat', 'fedora'
  package 'curl-devel'
end

execute "su - #{node[:user]} -c 'gem install gem-compare'" do
  not_if "su - #{node[:user]} -c 'gem which rubygems/comparator'"
end

# RPM start
if node.platform?('fedora', 'redhat', 'centos')
  package 'git-annex'

  github_project 'foreman-packaging' do
    path project_path('foreman-packaging')
    project_owner node[:user]
    user node[:user]
    branch 'rpm/develop'
    maintain_upstream true
  end

  package 'tito'

  file "/home/#{node[:user]}/.titorc" do
    content "KOJI_OPTIONS=-c ~/.koji/katello-config build --nowait"
    owner node[:user]
    group node[:user]
    mode '0644'
  end

  directory "/home/#{node[:user]}/.koji" do
    owner node[:user]
    group node[:user]
    mode '0755'
  end

  package 'koji'

  template "/home/#{node["user"]}/.koji/katello-config" do
    source 'foreman_packaging/katello-config.erb'
    owner node[:user]
    group node[:user]
    mode '0644'
  end

  cookbook_file "/home/#{node[:user]}/.koji/katello-ca.crt" do
    owner node[:user]
    group node[:user]
    mode '0644'
    source 'foreman_packaging/katello-ca.crt'
  end
  # todo - upload private cert to /home/#{node[:user]}/.koji/katello.crt
end
# RPM stop

# DEB start
if node.platform?('debian', 'ubuntu')
  package 'debhelper'
  package 'devscripts'

  github_project 'foreman-packaging' do
    path project_path('foreman-packaging')
    project_owner node[:user]
    user node[:user]
    branch 'deb/develop'
  end
end
# DEB stop
