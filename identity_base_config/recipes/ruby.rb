# Ruby environment / installation
rbenv_root = node.fetch('identity_shared_attributes').fetch('rbenv_root')

# sanity checks that identity-ruby correctly installed ruby in the base AMI
unless File.exist?(rbenv_root)
  raise "Cannot find rbenv_root at #{rbenv_root.inspect} -- was it created in the base AMI?"
end
unless File.exist?(rbenv_root + '/shims/ruby')
  raise "Cannot find ruby shim in rbenv_root under #{rbenv_root.inspect} -- was it created in the base AMI?"
end
unless File.exist?(rbenv_root + '/shims/gem')
  raise "Cannot find gem shim in rbenv_root under #{rbenv_root.inspect} -- was it created in the base AMI?"
end

global_env_vars = {
  'RBENV_ROOT' => rbenv_root,
  'PATH' => "/opt/chef/bin:#{rbenv_root}/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games",
  'RAILS_ENV' => 'production',
  'RACK_ENV' => 'production',
}

# Set proxy environment variables if present in Chef config
['http_proxy', 'https_proxy', 'no_proxy'].each do |proxy_variable|
  if Chef::Config.fetch(proxy_variable)
    Chef::Log.warn("Setting #{proxy_variable} to #{Chef::Config[proxy_variable]}")
    global_env_vars[proxy_variable] = Chef::Config[proxy_variable]
  end
end

# New Relic wants its proxy hostname and port separated. Our provision script
# leaves those in files in /etc/login.gov/info.
global_env_vars['NEW_RELIC_PROXY_HOST'] = node.fetch('identity_shared_attributes').fetch('proxy_server')
global_env_vars['NEW_RELIC_PROXY_PORT'] = node.fetch('identity_shared_attributes').fetch('proxy_port')

# hack to set all the env variables from /etc/environment such as PATH and
# RAILS_ENV for all subprocesses during this chef run
global_env_vars.each_pair do |key, val|
  ENV[key] = val
end

file '/etc/environment' do
  header = <<-EOM
    # Dropped off by chef
    # This is a static file (not script) used by PAM to set env variables.
  EOM
  content(
    header + global_env_vars.map { |key, val| "#{key}='#{val}'" }.join("\n") \
    + "\n"
  )
  notifies :run, 'execute[restart_snapd]'
end

execute 'restart_snapd' do
  command 'systemctl restart snapd'
  action :nothing
end

# install dependencies
package 'libpq-dev'
package 'libsasl2-dev'
