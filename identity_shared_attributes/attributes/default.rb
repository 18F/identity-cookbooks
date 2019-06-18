def read_env_file(filename)
  return nil unless ::File.exist?(filename)
  data = ::File.read(filename).chomp
  if data.empty?
    nil
  else
    data
  end
end

default[:identity_shared_attributes][:cache_dir] = '/var/cache/chef'
default[:identity_shared_attributes][:openssl_version] = '1.0.2s'
default[:identity_shared_attributes][:production_user] = 'websrv'
default[:identity_shared_attributes][:system_user] = 'appinstall'
default[:identity_shared_attributes][:proxy_server] = read_env_file('/etc/login.gov/info/proxy_server')
default[:identity_shared_attributes][:proxy_port] = read_env_file('/etc/login.gov/info/proxy_port')
default[:identity_shared_attributes][:rbenv_root] = '/opt/ruby_build'
