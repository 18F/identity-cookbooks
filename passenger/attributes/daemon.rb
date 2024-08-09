cache_dir = node.fetch(:identity_shared_attributes).fetch(:cache_dir)

# Use stable (even-numbered) version of NGINX
default[:nginx][:version] = '1.24.0'
default[:nginx][:headers_more][:version] = '0.37'

default[:nginx][:path] = '/opt/nginx'
default[:nginx][:headers_more_path] = node[:nginx][:path] +
  '/src/headers-more-nginx-module-' +
  node[:nginx][:headers_more][:version]

default[:nginx][:configure_flags] = "--with-http_stub_status_module \
  --with-http_ssl_module \
  --with-http_realip_module \
  --with-ld-opt=\"-L/usr/lib/x86_64-linux-gnu/lib\" \
  --with-cc-opt=\"-I/usr/include/x86_64-linux-gnu/openssl\" \
  --add-module=#{node[:nginx][:headers_more_path]}"

default[:nginx][:log_path] = '/var/log/nginx'

# Enable the nginx status server on 127.0.0.1
default[:nginx][:status_server] = true
