# thanks to https://github.com/asynchrony/chef-openssl-fips for the blunt of the work

cache_dir = node.fetch('identity_fips_openssl').fetch('cache_dir')
directory cache_dir do
  action :create
end

src_dirpath  = "#{cache_dir}/openssl-fips-#{node['identity_fips_openssl']['fips']['version']}"
src_filepath  = "#{src_dirpath}.tar.gz"

remote_file node['identity_fips_openssl']['fips']['url'] do
  source node['identity_fips_openssl']['fips']['url']
  checksum node['identity_fips_openssl']['fips']['checksum']
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

fips_dirpath = "#{cache_dir}/openssl-fipsmodule-#{node['identity_fips_openssl']['fips']['version']}"

execute 'compile_fips_source' do
  cwd src_dirpath
  command <<-EOH
    ./config --prefix=#{fips_dirpath} && make && make install
  EOH
  not_if { ::File.directory?(fips_dirpath) }
end

src_dirpath = "#{cache_dir}/openssl-#{node['identity_fips_openssl']['openssl']['version']}"
src_filepath = "#{src_dirpath}.tar.gz"
remote_file node['identity_fips_openssl']['openssl']['url'] do
  source node['identity_fips_openssl']['openssl']['url']
  checksum node['identity_fips_openssl']['openssl']['checksum']
  path src_filepath
  backup false
end

execute 'unarchive_openssl' do
  cwd ::File.dirname(src_filepath)
  command "tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}"
  not_if { ::File.directory?(src_dirpath) }
end

configure_flags = node['identity_fips_openssl']['openssl']['configure_flags'].map { |x| x }
configure_flags << "--prefix=#{node['identity_fips_openssl']['openssl']['prefix']}"
configure_flags << "fips" << "--with-fipsdir=#{fips_dirpath}"

execute 'compile_openssl_source' do
  cwd  src_dirpath
  command "./config #{configure_flags.join(' ')} && make && make install"
  not_if { ::File.directory?(node['identity_fips_openssl']['openssl']['prefix']) }
end

execute 'link certs dir' do
  cwd node['identity_fips_openssl']['openssl']['prefix']
  command "rmdir ssl/certs ; ln -s /usr/lib/ssl/certs ssl/certs"
  not_if { ::File.symlink?("#{node['identity_fips_openssl']['openssl']['prefix']}/ssl/certs")}
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
  content "#{node['identity_fips_openssl']['openssl']['prefix']}/bin/openssl\n"
  mode '0644'
  owner 'root'
  group 'root'
end
