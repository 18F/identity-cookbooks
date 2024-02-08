cache_dir = node.fetch(:identity_shared_attributes).fetch(:cache_dir)

default[:passenger][:production][:version] = '6.0.20'
# Use stable (even-numbered) version of NGINX
default[:passenger][:production][:nginx][:version] = '1.24.0'
default[:passenger][:production][:headers_more][:version] = '0.37'

default[:passenger][:production][:path] = '/opt/nginx'
default[:passenger][:production][:native_support_dir] = node.fetch(:passenger).fetch(:production).fetch(:path) + '/passenger-native-support'
default[:passenger][:production][:headers_more_path] = node[:passenger][:production][:path] +
  '/src/headers-more-nginx-module-' +
  node[:passenger][:production][:headers_more][:version]

default[:passenger][:production][:configure_flags] = "--with-ipv6 \
  --with-http_stub_status_module \
  --with-http_ssl_module \
  --with-http_realip_module \
  --with-ld-opt=\"-L/usr/lib/x86_64-linux-gnu/lib\" \
  --with-cc-opt=\"-I/usr/include/x86_64-linux-gnu/openssl\" \
  --add-module=#{node[:passenger][:production][:headers_more_path]}"

default[:passenger][:production][:log_path] = '/var/log/nginx'

# Enable the status server on 127.0.0.1
default[:passenger][:production][:status_server] = true
