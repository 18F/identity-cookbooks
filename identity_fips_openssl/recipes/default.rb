# Thanks to https://github.com/asynchrony/chef-openssl-fips for the brunt of the work

cache_dir = node.fetch('identity_fips_openssl').fetch('cache_dir')
directory cache_dir do
  action :create
end

fips_config = node.fetch('identity_fips_openssl').fetch('fips')

src_dirpath  = "#{cache_dir}/openssl-fips-#{fips_config.fetch('version')}"
src_filepath  = "#{src_dirpath}.tar.gz"

remote_file fips_config.fetch('url') do
  source fips_config.fetch('url')
  checksum fips_config.fetch('checksum')
  path src_filepath
  backup false
end

execute 'unarchive_fips' do
  cwd ::File.dirname(src_filepath)
  command <<-EOH
    tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
  EOH
  not_if { ::File.directory?(src_dirpath) }
end

fips_dirpath = "#{cache_dir}/openssl-fipsmodule-#{fips_config.fetch('version')}"

execute 'compile_fips_source' do
  cwd src_dirpath
  command <<-EOH
    ./config --prefix=#{fips_dirpath} && make && make install
  EOH
  not_if { ::File.directory?(fips_dirpath) }
end

openssl_config = node.fetch('identity_fips_openssl').fetch('openssl')
src_dirpath = "#{cache_dir}/openssl-#{openssl_config.fetch('version')}"
src_filepath = "#{src_dirpath}.tar.gz"
remote_file openssl_config.fetch('url') do
  source openssl_config.fetch('url')
  checksum openssl_config.fetch('checksum')
  path src_filepath
  backup false
end

execute 'unarchive_openssl' do
  cwd ::File.dirname(src_filepath)
  command "tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}"
  not_if { ::File.directory?(src_dirpath) }
end

configure_flags = openssl_config.fetch('configure_flags').map { |x| x }
configure_flags << "--prefix=#{openssl_config.fetch('prefix')}"
configure_flags << "fips" << "--with-fipsdir=#{fips_dirpath}"

execute 'compile_openssl_source' do
  cwd  src_dirpath
  command "./config #{configure_flags.join(' ')} && make && make install"
  not_if { ::File.directory?(openssl_config.fetch('prefix')) }
end

#record binary location for chef deployment to access
directory '/etc/login.gov/info' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

file '/etc/login.gov/info/openssl_binary' do
  content "#{openssl_config.fetch('prefix')}/bin/openssl\n"
  mode '0644'
  owner 'root'
  group 'root'
end
