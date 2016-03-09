github_project 'theforeman.org' do
  path project_path('theforeman.org')
  user node[:user]
  project_owner node[:user]
  branch 'gh-pages'
end
