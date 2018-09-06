require 'chefspec'

describe 'passenger::daemon' do

  let(:chef_run) {
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
      node.normal['cloud']['local_ipv4'] = '1.2.3.4'
      node.normal['identity-ruby']['rbenv_root'] = '/opt/ruby_build'
    end.converge(described_recipe)
  }
  it 'creates nginx.conf' do
    expect(chef_run).to create_template('/opt/nginx/conf/nginx.conf')
  end
end
