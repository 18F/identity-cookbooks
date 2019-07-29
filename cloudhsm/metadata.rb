name 'cloudhsm'
maintainer 'The Login.gov Team'
maintainer_email 'identity-devops@login.gov'
license 'CC0-1.0'
description 'AWS CloudHSM config cookbook'
long_description 'Resources and recipes for discovering CloudHSM clusters and setting up CloudHSM client libraries'
version '0.0.8'
chef_version '>= 13.0' if respond_to?(:chef_version)

issues_url 'https://github.com/18F/identity-cookbooks/issues'
source_url 'https://github.com/18F/identity-cookbooks'

gem 'aws-sdk-cloudhsmv2', '~> 1.18'
