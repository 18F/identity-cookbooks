default['config_loader']['bucket_prefix'] = nil
default['citadel']['region'] = Chef::Recipe::AwsMetadata.get_aws_region
default['citadel']['bucket'] = "#{node['config_loader']['bucket_prefix']}.#{Chef::Recipe::AwsMetadata.get_aws_account_id}-#{Chef::Recipe::AwsMetadata.get_aws_region}"
