# TODO needs more work
# - adding attributes to foreman and smart proxy plugins to install them
github_project "puppet-foreman_scap_client" do
  path "/etc/puppet/code/environments/production/modules/puppet-foreman_scap_client"
  user node[:user]
  project_owner node[:user]
end
