require 'json'

class Chef::Recipe::ConfigLoader
  def self.load_config(node, key, common: false)
    url = "s3://#{node['login_dot_gov']['secrets_bucket']}"
    prefix = common ? "common" : node.chef_environment
    url = "#{url}/#{prefix}/#{key}"
    result = `aws s3 cp #{url} - 2>&1`.chomp
    if $?.success?
      result
    else
      raise result
    end
  end

  # Like load_config, but return nil with a warning if s3 receives an HTTP
  # 404 response code. This only applies to cases where node.chef_environment
  # is not "prod". In the "prod" environment, always raise on errors and never
  # return nil.
  def self.load_config_or_nil(node, key, print_warnings: true)
    raw = load_config(node, key)
  rescue StandardError => err
    if (err.message =~ /An error occurred \(404\)/ &&
        node.chef_environment != "prod")
      Chef::Log.warn(err.message) if print_warnings
      return nil
    else
      raise
    end
  end

  # Like load_config, but designed to handle nested secrets data. If the
  # contents are being loaded, also JSON.parse the data.
  def self.load_json(node, key, common: false)
    url = "s3://#{node['login_dot_gov']['secrets_bucket']}"
    prefix = common ? "common" : node.chef_environment
    url = "#{url}/#{prefix}/#{key}"
    raw = `aws s3 cp #{url} - 2>&1`.chomp
    if $?.success?
      JSON.parse(raw)
    else
      raise raw
    end
  end
end
