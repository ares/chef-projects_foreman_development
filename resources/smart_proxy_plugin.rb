resource_name :smart_proxy_plugin

property :id, :kind_of => String, :name_property => true
property :plugin, :kind_of => Hash
property :main_project_path, :kind_of => String

default_action :install

action :install do
  bundled_plugin new_resource.name do
    plugin new_resource.plugin
    main_project_path new_resource.main_project_path
  end

  template "#{new_resource.main_project_path}/config/settings.d/#{new_resource.plugin[:module_name]}.yml" do
    owner node[:user]
    group node[:user]
    mode '0644'
    source "smart_proxy/#{new_resource.plugin[:module_name]}.yml.example"
    variables :smart_proxy_plugin => new_resource
  end
end
