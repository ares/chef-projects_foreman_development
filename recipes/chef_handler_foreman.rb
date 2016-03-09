github_project 'chef-handler-foreman' do
  path project_path('chef-handler-foreman')
  project_owner node[:user]
  user node[:user]
  maintain_upstream true
end
