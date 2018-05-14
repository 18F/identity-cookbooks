#
# Cookbook:: identity_base_config
# Recipe:: default
#
# Common packages and config used by all hosts

package [
  'aptitude',
  'bmon',
  'bwm-ng',
  'colordiff',
  'dstat',
  'htop',
  'iftop',
  'iotop',
  'iperf',
  'moreutils',
  'ncdu',
  'nethogs',
  'pigz',
  'pv',
  'pydf',
  'tree',

  'build-essential',
  'libpq-dev',
  'libsasl2-dev',
  'libffi-dev',
]

# linux perf
package [
  'linux-tools-common',
  'linux-tools-aws',
]

package 'python-pip'

execute 'install awscli as needed' do
  command 'pip install awscli'
  not_if { File.exist?('/usr/local/bin/aws') }
end

# common scripts and aliases

cookbook_file '/usr/local/bin/id-apt-upgrade' do
  source 'id-apt-upgrade'
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/usr/local/bin/id-chef-client' do
  source 'id-chef-client'
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/usr/local/bin/id-git' do
  source 'id-git'
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/usr/local/bin/git-with-key' do
  source 'git-with-key'
  owner 'root'
  group 'root'
  mode '0755'
end
