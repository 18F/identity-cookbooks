#
# Cookbook Name:: passenger
# Recipe:: production

include_recipe "passenger::install"

%w(curl jq).each do |pkg|
  package pkg do
    retries 12
    retry_delay 5
  end
end

platform_packages = []
case node[:platform_version]
when '18.04'
  platform_packages.push('libcurl4-gnutls-dev')
# Needs libpcre3 installed otherwise nginx compiles --without-http_rewrite_module
when '20.04'
  platform_packages.push('libpcre3','libpcre3-dev','libcurl4-gnutls-dev')
end

platform_packages.each do |pkg|
  package pkg do
    retries 12
    retry_delay 5
  end
end

nginx_path           = node.fetch(:passenger).fetch(:production).fetch(:path)
nginx_version        = node[:passenger][:production][:nginx][:version]
headers_more_version = node[:passenger][:production][:headers_more][:version]

directory "#{nginx_path}/src" do
  mode 0755
  action :create
  recursive true
end

cookbook_file "#{nginx_path}/src/fipsmode.patch" do
  source "fipsmode.patch"
end

# Download nginx src into #{nginx_path}/src/ and patch it to enable FIPS mode
bash "download nginx source and patch for FIPS mode" do
  code <<-EOH
  cd #{nginx_path}/src
  wget https://nginx.org/download/nginx-#{nginx_version}.tar.gz
  tar zxpf nginx-#{nginx_version}.tar.gz
  cd nginx-#{nginx_version}
  patch -p1 < ../fipsmode.patch
  EOH
  not_if "test -d #{nginx_path}/src/nginx-#{nginx_version}"
end

remote_file "#{node[:passenger][:production][:headers_more_path]}.tar.gz" do
  source 'https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v' +
    headers_more_version +
    '.tar.gz'
end

execute "tar xzvf #{node[:passenger][:production][:headers_more_path]}.tar.gz -C #{nginx_path}/src"

bash "install passenger/nginx" do
  code <<-EOH
  cd #{nginx_path}/src/nginx-#{nginx_version}
  sh ./configure --prefix='#{nginx_path}' --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_gzip_static_module --with-http_stub_status_module --with-http_addition_module #{node[:passenger][:production][:configure_flags]}
  make
  make install
  EOH
  not_if "test -e #{nginx_path}/sbin/nginx"
end

log_path = node[:passenger][:production][:log_path]

directory log_path do
  mode 0750
  action :create
  owner 'root'
  group 'adm'
end

nginx_path_logs = nginx_path + '/logs'

execute 'backup existing nginx logs' do
  command %W{mv -vT #{nginx_path_logs} #{nginx_path_logs + '.backup'}}
  only_if { File.directory?(nginx_path_logs) && !File.symlink?(nginx_path_logs) }
end

# make a symlink from nginx/logs/ to our desired log_path
link nginx_path_logs do
  to log_path
end

directory "#{nginx_path}/conf/conf.d" do
  mode 0755
  action :create
  recursive true
end

directory "#{nginx_path}/conf/sites.d" do
  mode 0755
  action :create
  recursive true
end

cookbook_file "#{nginx_path}/conf/status-map.conf" do
  source "status-map.conf"
  mode "0644"
end

extend Chef::Mixin::ShellOut

template "/etc/init.d/passenger" do
  source "passenger.init.erb"
  owner "root"
  group "root"
  mode 0755
  sensitive true
  variables(
    :pidfile => "#{nginx_path}/nginx.pid",
    :nginx_path => nginx_path
  )
end

# set proxy environment variables in passenger
# could alternatively source /etc/profile.d/proxy-config.sh, but it won't exist
# if the proxy isn't enabled
file "/etc/default/passenger" do
  content <<-EOM
export http_proxy=#{Chef::Config['http_proxy']}
export https_proxy=#{Chef::Config['https_proxy']}
export no_proxy=#{Chef::Config['no_proxy']}
  EOM
end

if node[:passenger][:production][:status_server]
  cookbook_file "#{nginx_path}/conf/sites.d/status.conf" do
    source "status.conf"
    mode "0644"
  end
end

service 'passenger' do
  action [:disable, :stop]
end
