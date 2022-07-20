cache_dir = node.fetch(:identity_shared_attributes).fetch(:cache_dir)

default[:passenger][:production][:path] = '/opt/nginx'
default[:passenger][:production][:native_support_dir] = node.fetch(:passenger).fetch(:production).fetch(:path) + '/passenger-native-support'

default[:passenger][:production][:configure_flags] = "--with-ipv6 --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module --with-ld-opt=\"-L/usr/lib/x86_64-linux-gnu/lib\" --with-cc-opt=\"-I/usr/include/x86_64-linux-gnu/openssl\""
default[:passenger][:production][:log_path] = '/var/log/nginx'
# Relevant for any NGINX instance behind an ALB
default[:passenger][:production][:log_alb_headers] = true
# Relevant only when client certificates are passed directly to NGINX
default[:passenger][:production][:log_client_ssl] = false

# Enable the status server on 127.0.0.1
default[:passenger][:production][:status_server] = true

default[:passenger][:production][:user] = node.fetch(:identity_shared_attributes).fetch(:production_user)
default[:passenger][:production][:version] = '6.0.14'
# Use stable (even-numbered) version of NGINX
default[:passenger][:production][:nginx][:version] = '1.22.0'

# Adds Cloudfront CIDRS to the set_real_ip_from to allow for proper client ip preservation
default[:passenger][:production][:enable_cloudfront_support] = true

# Tune the following configurations for your environment. For more info see:
# https://www.phusionpassenger.com/library/config/nginx/optimization
default[:passenger][:production][:gzip] = true

# Nginx's default is 0, but we don't want that.
default[:passenger][:production][:keepalive_timeout] = '60 50'

default[:passenger][:production][:limit_connections] = true

# Keep max_pool_size and min_instances the same to create a fixed process pool
default[:passenger][:production][:max_pool_size] = node.fetch('cpu').fetch('total') * 2
default[:passenger][:production][:min_instances] = node.fetch('cpu').fetch('total') * 2

default[:passenger][:production][:max_instances_per_app] = 0
default[:passenger][:production][:pool_idle_time] = 0

# a list of URL's to pre-start.
default[:passenger][:production][:pre_start] = []

default[:passenger][:production][:sendfile] = true
default[:passenger][:production][:tcp_nopush] = false

# Set worker processes to number of CPU cores until benchmarking shows that we
# should do otherwise. See:
# http://nginx.org/en/docs/ngx_core_module.html#worker_processes
default[:passenger][:production][:worker_processes] = node.fetch('cpu').fetch('total')
default[:passenger][:production][:worker_connections] = 1024
default[:passenger][:production][:nofile_limit] =  node.fetch('passenger').fetch('production').fetch('worker_connections') * 2
