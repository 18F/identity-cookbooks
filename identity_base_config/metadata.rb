name 'identity_base_config'
maintainer 'The Login.gov Team'
maintainer_email 'identity-devops@login.gov'
license 'CC0-1.0'
description 'Identity base config and packages'
long_description 'Identity base config and packages'
version '0.1.2'
chef_version '>= 13.0' if respond_to?(:chef_version)

issues_url 'https://github.com/18F/identity-cookbooks/issues'
source_url 'https://github.com/18F/identity-cookbooks'

depends 'identity_shared_attributes'
