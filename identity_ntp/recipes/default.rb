package 'ntp' do
  action :upgrade
end

template '/etc/ntp.conf' do
  source 'ntp.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[ntp]'
end

service 'ntp' do
  action [ :enable, :start ]
end
