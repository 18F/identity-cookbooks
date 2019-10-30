name 'identity_fips_openssl'
maintainer 'Login.gov team'
maintainer_email 'identity-devops@login.gov'
license 'All Rights Reserved'
description 'FIPS OpenSSL module compilation'
long_description 'Compiles and installs the OpenSSL FIPS module'
version '0.2.0'
chef_version '>= 13.0' if respond_to?(:chef_version)

depends 'identity_shared_attributes', '>= 0.1.2'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
source_url 'https://github.com/18F/identity-cookbooks'