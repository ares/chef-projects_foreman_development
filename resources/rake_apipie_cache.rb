resource_name :rake_apipie_cache

property :path, :kind_of => String, :name_property => true
property :user, :kind_of => String
property :env, :kind_of => Hash

default_action :cache

action :cache do
  if new_resource.env.empty?
    env = ''
  else
    env = new_resource.env.map { |key, value| "export #{key.upcase}=#{value};"}.join(' ')
  end

  execute "su - #{new_resource.user} -c '#{env} cd #{new_resource.path}; bundle exec rake apipie:cache > #{new_resource.path}/log/init_apipie_cache.log'" do
    not_if { ::File.exists?("#{new_resource.path}/log/init_apipie_cache.log") }
  end
end
