package 'ntp' do
  action :remove
end

# Assert that we're on an expected OS release
release = node.fetch('lsb').fetch('release')
case release
when '18.04', '20.04', '22.04'
  # OK
else
  raise NotImplementedError.new("Unexpected OS release: #{release.inspect}")
end

package 'systemd-timesyncd'

file '/etc/systemd/timesyncd.conf' do
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[systemd-timesyncd]', :immediate
  content <<-EOM
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#
# Entries in this file show the compile time defaults.
# You can change settings by editing this file.
# Defaults can be restored by simply deleting this file.
#
# See timesyncd.conf(5) for details.

[Time]
# Use the EC2 NTP service
# https://aws.amazon.com/blogs/aws/keeping-time-with-amazon-time-sync-service/
NTP=169.254.169.123
FallbackNTP=
#RootDistanceMaxSec=5
#PollIntervalMinSec=32
#PollIntervalMaxSec=2048
  EOM
end

service 'systemd-timesyncd' do
  action [ :enable, :start ]
end
