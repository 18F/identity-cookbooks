#
# Cookbook Name:: identity_ossec
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'ossec'

# custom syslog_rules which removes rule 1003
cookbook_file '/var/ossec/rules/syslog_rules.xml' do
  source 'syslog_rules.xml'
  owner 'root'
  group 'ossec'
  mode '0550'
end

execute '/var/ossec/bin/ossec-control enable client-syslog' do
  not_if "ps gaxuwww | grep ossec-csyslogd | grep -v grep"
  notifies :restart, 'service[ossec]'
end

template '/etc/rsyslog.d/60-localsyslog.conf' do
  source '60-localsyslog.erb'
  notifies :run, 'execute[restart_rsyslog]'
end

execute 'restart_rsyslog' do
  command 'service rsyslog restart'
  action :nothing
end

# fix up init.d directory so
# service will start on boot
link '/etc/init.d/ossec' do
  action :delete
end

remote_file "Copy file to init.d" do
  source "file:///var/ossec/etc/init.d/ossec"
  path "/etc/init.d/ossec"
  owner 'root'
  group 'root'
  mode 0755
end

apt_repository 'ossec' do
  action :remove
end