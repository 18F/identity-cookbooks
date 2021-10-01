name 'config_loader'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures config_loader'
long_description 'Installs/Configures config_loader'
version '0.3.0'
chef_version '>= 12.15.19' if respond_to?(:chef_version)

# both of these dependencies must also be within the top-level Berksfile
# for this cookbook to operate correctly
depends 'aws_metadata'
