github_project 'community-templates' do
  path project_path('community-templates')
  project_owner node[:user]
  user node[:user]
  branch 'develop'
end
