# Helper class for getting AWS info for the currently running instance
class Chef::Recipe::AwsMetadata

  # Fetch and parse the instance identity document from the EC2 metadata API
  #
  # @return [Hash]
  def self.get_instance_identity
    c = Chef::HTTP.new('http://169.254.169.254')
    v2_token = c.put("/latest/api/token", nil, { 'X-aws-ec2-metadata-token-ttl-seconds': "120" })
    doc = c.get('/2016-09-02/dynamic/instance-identity/document', { 'X-aws-ec2-metadata-token' => v2_token } )
    { 'Accept' => 'text/html' }
    JSON.parse(doc)
  end

  def self.get_aws_account_id
    get_instance_identity.fetch('accountId')
  end

  def self.get_aws_instance_id
    get_instance_identity.fetch('instanceId')
  end

  def self.get_aws_region
    get_instance_identity.fetch('region')
  end

  def self.get_aws_vpc_id
    c = Chef::HTTP.new('http://169.254.169.254')
    v2_token = c.put("/latest/api/token", nil, { 'X-aws-ec2-metadata-token-ttl-seconds': "120" })
    interfaces = c.get('/2016-09-02/meta-data/network/interfaces/macs/', { 'X-aws-ec2-metadata-token' => v2_token })
    interfaces = interfaces.split("\n").map { |interface| interface.chomp("/") }
    c.get("/2016-09-02/meta-data/network/interfaces/macs/#{interfaces.fetch(0)}/vpc-id", { 'X-aws-ec2-metadata-token' => v2_token })
  end

  def self.get_aws_vpc_cidr
    c = Chef::HTTP.new('http://169.254.169.254')
    v2_token = c.put("/latest/api/token", nil, { 'X-aws-ec2-metadata-token-ttl-seconds': "120" })
    interfaces = c.get('/2016-09-02/meta-data/network/interfaces/macs/', { 'X-aws-ec2-metadata-token' => v2_token })
    interfaces = interfaces.split("\n").map { |interface| interface.chomp("/") }
    c.get("/2016-09-02/meta-data/network/interfaces/macs/#{interfaces.fetch(0)}/vpc-ipv4-cidr-block", { 'X-aws-ec2-metadata-token' => v2_token })
  end
end
