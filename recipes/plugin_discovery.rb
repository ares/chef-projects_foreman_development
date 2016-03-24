# it checks etag and modified since headers and updates the file if it changed
# on debian, the path might be /srv/tftp/boot it needs testing
remote_file '/var/lib/tftpboot/boot/fdi-image-latest.tar' do
  source 'http://downloads.theforeman.org/discovery/releases/latest/fdi-image-latest.tar'
  owner node[:user]
  group node[:user]
  mode '0755'
  notifies :run, 'script[extract_discovery_files]', :immediately
end

script 'extract_discovery_files' do
  action :nothing
  user node[:user]
  group node[:user]
  interpreter 'bash'
  cwd '/var/lib/tftpboot/boot/'
  code <<-EOS
    tar xvvf fdi-image-latest.tar
  EOS
end

cookbook_file project_path('foreman/tmp/pxe_linux_global_default.erb') do
  source 'foreman/pxe_linux_global_default.erb'
end
