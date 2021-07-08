name 'auto_hostname'
maintainer 'Andy Brody'
maintainer_email 'andrew.brody@gsa.gov'
license 'All Rights Reserved'
description 'Sets hostname dynamically at boot'
long_description 'Sets hostname automatically at runtime for EC2 instances'
version '0.1.0'
chef_version '>= 13.8' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/auto_hostname/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/auto_hostname'
