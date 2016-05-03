resource_name :foreman_plugin_seed_script

property :name, :kind_of => String, :name_property => true

default_action :create

action :create do
  directory "#{project_path('foreman')}/tmp/plugins.d" do
    mode '0755'
    owner node[:user]
    group node[:user]
    action :create
  end

  template "#{project_path('foreman')}/tmp/plugins.d/#{new_resource.name}" do
    source "foreman/#{new_resource.name}.erb"
    mode '0755'
    owner node[:user]
    group node[:user]
    variables :seed_path => "#{project_path('foreman')}/tmp/"
  end
end



