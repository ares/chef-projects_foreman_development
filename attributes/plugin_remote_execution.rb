node.default[:projects][:foreman][:plugins][:foreman_remote_execution] = project_attributes('foreman_remote_execution').last
node.default[:projects][:hammer][:plugins][:hammer_cli_foreman_remote_execution] = project_attributes('hammer_cli_foreman_remote_execution', :module_name => 'hammer_cli_foreman_remote_execution').last
