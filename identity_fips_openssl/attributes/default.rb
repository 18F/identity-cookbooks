default['identity_fips_openssl']['cache_dir']                  = default.fetch(:identity_shared_attributes).fetch(:cache_dir) # /var/cache/chef
default['identity_fips_openssl']['fips']['version']            = '2.0.16'
default['identity_fips_openssl']['fips']['url']                = "https://www.openssl.org/source/openssl-fips-#{default['identity_fips_openssl']['fips']['version']}.tar.gz"
default['identity_fips_openssl']['fips']['checksum']           = 'a3cd13d0521d22dd939063d3b4a0d4ce24494374b91408a05bdaca8b681c63d4'
default['identity_fips_openssl']['openssl']['version']         = '1.0.2q'
default['identity_fips_openssl']['openssl']['prefix']          = "/opt/openssl-#{default['identity_fips_openssl']['openssl']['version']}"
default['identity_fips_openssl']['openssl']['url']             = "https://www.openssl.org/source/openssl-#{default['identity_fips_openssl']['openssl']['version']}.tar.gz"
default['identity_fips_openssl']['openssl']['checksum']        = '5744cfcbcec2b1b48629f7354203bc1e5e9b5466998bbccc5b5fcde3b18eb684'
default['identity_fips_openssl']['openssl']['configure_flags'] = %W[ shared ]

