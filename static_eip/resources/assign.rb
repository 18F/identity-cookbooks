resource_name :static_eip_assign

property :name, String, default: 'assign static EIP'
property :role, String
property :environment, String
property :data_bag_name, String, default: 'private'
property :data_bag_item_name, String, default: 'auto_eip_config'
property :sentinel_file, String

action :create do

  # ['python','python-netaddr'].each do |pkg|
  #   package pkg do
  #     retries 12
  #     retry_delay 5
  #   end
  # end

  # execute 'apt-get -q -y remove python-pip-whl'
  # package 'python3-pip' do
  #   retries 12
  #   retry_delay 5
  # end

  # execute 'pip3 install aws-ec2-assign-elastic-ip'

  # configuration comes from a data bag with specified name and item_name
  # (default private/auto_eip_config.json)
  #
  # Structure inside the data bag should look like:
  #
  # {
  #   "environments": {
  #     "qa": {
  #       "worker": {
  #         "valid_ips": "192.0.2.128/25,192.0.2.5",
  #         "invalid_ips": null
  #       },
  #       "jumphost": {
  #         "valid_ips": "192.0.2.7,192.0.2.8",
  #         "invalid_ips": "192.0.2.5"
  #       }
  #     },
  #     "prod": {
  #       "worker": {
  #         "valid_ips": "192.0.2.128/25"
  #       }
  #     }
  #   }
  # }
  #
  # The valid_ips and invalid_ips strings will be passed directly to
  # aws-grab-static-eip.

  bag_name = new_resource.data_bag_name
  bag_item_name = new_resource.data_bag_item_name
  begin
    data_bag(bag_name)
  rescue Net::HTTPServerException
    Chef::Log.error("Failed to load data bag #{bag_name.inspect}")
    raise
  end

  begin
    eips_config = data_bag_item(bag_name, bag_item_name)
  rescue Net::HTTPServerException
    Chef::Log.error("Couldn't find data bag item #{bag_item_name.inspect} in data bag #{bag_name.inspect}")
    raise
  end

  begin
    env_config = eips_config.fetch('environments').fetch(new_resource.environment)
  rescue KeyError
    Chef::Log.error("Failed to find environment config in #{bag_name.inspect}/#{bag_item_name.inspect}")
    raise
  end

  role_config = env_config.fetch(new_resource.role)

  valid_ips = role_config.fetch('valid_ips')
  invalid_ips = role_config['invalid_ips']

  # require valid_ips to be present, allow invalid_ips to be absent
  unless valid_ips.is_a?(String)
    raise ArgumentError.new("must have valid_ips key in env config in #{bag_item_name.inspect}")
  end

  cookbook_file '/usr/local/bin/assign-iep' do
    source 'assign_eip.bash'
    owner 'root'
    group 'root'
    mode '0755'
  end

  cookbook_file '/usr/local/bin/find-available-eip' do
    source 'find_available_eip.rb'
    owner 'root'
    group 'root'
    mode '0755'
  end

  assign_opts = [valid_ips]
  assign_opts += [invalid_ips] if invalid_ips

  execute 'assign eips' do
    command ['assign-iep'] + assign_opts
    notifies :run, 'execute[sleep after eip assignment]', :immediately
    not_if { ::File.exist?(new_resource.sentinel_file) }
    live_stream true

    # Retry assignment a few times. We can fail the first time if we hit the
    # race condition where another instance grabs the same EIP we are
    # attempting to grab.
    retries 4
    retry_delay 5
  end

  # sleep after assigning an EIP so that we don't attempt to do stuff involving
  # the network during the cutover
  execute 'sleep after eip assignment' do
    command "touch '#{new_resource.sentinel_file}'"
    action :nothing
  end
end
