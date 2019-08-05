require 'chefspec'

describe 'identity_ntp::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '18.04').converge(described_recipe) }

  it 'creates /etc/ntp.conf' do
    expect(chef_run).to create_file('/etc/systemd/timesyncd.conf')
  end
end
