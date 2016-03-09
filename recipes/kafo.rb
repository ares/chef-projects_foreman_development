github_project 'kafo' do
  path project_path('kafo')
  project_owner node[:user]
  user node[:user]
end

github_project 'kafo_parsers' do
  path project_path('kafo_parsers')
  project_owner node[:user]
  user node[:user]
end
