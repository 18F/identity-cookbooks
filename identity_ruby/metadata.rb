name 'identity_ruby'
maintainer 'Login.gov team'
maintainer_email 'identity-devops@login.gov'
license 'All Rights Reserved'
description 'Login.gov ruby installation'
long_description 'Installs/Configures ruby versions with rbenv'
version '0.2.0'
chef_version '>= 13.0' if respond_to?(:chef_version)

depends 'identity_shared_attributes', '>= 0.1.2'
depends 'ruby_build', '= 1.2'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/identity_ruby'
