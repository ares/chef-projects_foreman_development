# install default RSA key pair
cookbook_file "/home/#{node[:user]}/.ssh/id_rsa_smart_proxy" do
  source 'smart_proxy/id_rsa_smart_proxy'
  owner node[:user]
  group node[:user]
  mode 0600
end

cookbook_file "/home/#{node[:user]}/.ssh/id_rsa_smart_proxy.pub" do
  source 'smart_proxy/id_rsa_smart_proxy.pub'
  owner node[:user]
  group node[:user]
  mode 0644
end
