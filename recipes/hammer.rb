github_project 'hammer-cli' do
  path project_path('hammer-cli')
  project_owner node[:user]
  user node[:user]
end

directory "/home/#{node[:user]}/.hammer" do
  owner node[:user]
  group node[:user]
  mode '0755'
end

template "/home/#{node[:user]}/.hammer/cli_config.yml" do
  owner node[:user]
  group node[:user]
  mode '0644'
  source 'hammer/cli_config.yml.erb'
end

node[:projects][:hammer][:plugins].each do |_, plugin|
  github_project plugin[:name] do
    path project_path(plugin[:name])
    project_owner node[:user]
    user node[:user]
  end
end

template "#{project_path('hammer-cli')}/Gemfile.local" do
  owner node[:user]
  group node[:user]
  mode '0644'
  source 'gemfile.erb'
  variables :gems => node[:projects][:hammer][:plugins]
end

bundle_install project_path('hammer-cli') do
  user node[:user]
end
