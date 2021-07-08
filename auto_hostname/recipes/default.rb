#
# Cookbook:: auto_hostname
# Recipe:: default

# Script to set hostname and /etc/hosts
cookbook_file '/usr/local/bin/auto-set-ec2-hostname' do
  source 'auto-set-ec2-hostname'
  owner 'root'
  group 'root'
  mode '0755'
end

case node[:platform_version]
when '16.04', '17.04', '17.10', '18.04'
  # use systemd in newer ubuntu releases

  cookbook_file '/etc/systemd/system/auto-ec2-hostname.service' do
    source 'auto-ec2-hostname.service'
    owner 'root'
    group 'root'
    mode '0644'
  end

when '14.04'
  # use sysv init in older ubuntu releases

  cookbook_file '/etc/init.d/auto-ec2-hostname' do
    source 'auto-ec2-hostname.init-d'
    owner 'root'
    group 'root'
    mode '0755'
    notifies :enable, 'service[auto-ec2-hostname]'
    notifies :start, 'service[auto-ec2-hostname]'
  end

else
  raise "Unexpected ubuntu platform_version: #{node[:platform_version].inspect}"
end

service 'auto-ec2-hostname' do
  supports start: true
  action :enable
end

directory '/etc/auto-hostname' do
  owner 'root'
  group 'root'
  mode '0755'
end

file '/etc/auto-hostname/domain' do
  content "login.gov\n"
  owner 'root'
  group 'root'
  mode '0644'
end

file '/etc/auto-hostname/prefix' do
  content "hardened\n"
  owner 'root'
  group 'root'
  mode '0644'
end
