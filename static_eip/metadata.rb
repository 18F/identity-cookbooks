name 'static_eip'
maintainer 'The Login.gov Team'
maintainer_email 'identity-devops@login.gov'
license 'CC0-1.0'
description 'Automatic EIP association cookbook'
long_description 'Picks an EIP from a configured range and automatically grabs it for the instance based on role'
version '0.1.0'
chef_version '>= 13.0' if respond_to?(:chef_version)

issues_url 'https://github.com/18F/identity-cookbooks/issues'
source_url 'https://github.com/18F/identity-cookbooks'
