node.default[:projects][:foreman][:plugins][:foreman_discovery] = project_attributes('foreman_discovery').last
node.default[:projects][:hammer][:plugins][:hammer_cli_foreman_discovery] = project_attributes('hammer-cli-foreman-discovery', :module_name => 'hammer_cli_foreman_discovery', :gem_name => 'hammer_cli_foreman_discovery').last
