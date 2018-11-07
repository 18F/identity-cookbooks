#
# Cookbook Name:: passenger
# Recipe:: install

gem_package "passenger/system" do
  gem_binary (node.fetch(:identity_shared_attributes).fetch(:rbenv_root) + '/shims/gem')
  package_name 'passenger'
  version node[:passenger][:production][:version]
  notifies :run, 'execute[rbenv rehash]', :immediately
end

execute 'rbenv rehash' do
  action :nothing # notify only
end
