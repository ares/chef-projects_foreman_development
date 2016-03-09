default[:projects][:foreman] = {
  :password => 'changeme',
  :setup_libvirt => true,
  :plugins => Hash[[
                     project_attributes('foreman_remote_execution'),
                     project_attributes('foreman-tasks'),
                     project_attributes('foreman_chef', :maintain_upstream => true),
                   ]]
}

default[:projects][:hammer] = {
  :plugins => Hash[[
                     project_attributes('hammer-cli-foreman', :module_name => 'hammer_cli_foreman')
                   ]]
}

default[:projects][:smart_proxy] = {
  :plugins => Hash[[
                     project_attributes('smart_proxy_dynflow', :module_name => 'dynflow'),
                     project_attributes('smart_proxy_remote_execution_ssh', :module_name => 'remote_execution_ssh'),
                     project_attributes('smart_proxy_chef', :maintain_upstream => true, :module_name => 'chef'),
                   ]]
}

default[:projects][:chef] = {
  :chef_url => 'https://chef.example.tst',
  :pivotal_file => '/etc/chef/pivotal.pem'
}
