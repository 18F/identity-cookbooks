# install cloudhsm client packages

# TODO pull from attribute
installers_dir = '/opt/aws/installers'

directory installers_dir do
  recursive true
end

remote_file "#{installers_dir}/cloudhsm-client-pkcs11_latest_amd64.deb" do
  source 'https://s3.amazonaws.com/cloudhsmv2-software/cloudhsm-client-pkcs11_latest_amd64.deb'
end

remote_file "#{installers_dir}/cloudhsm-client_latest_amd64.deb" do
  source 'https://s3.amazonaws.com/cloudhsmv2-software/cloudhsm-client_latest_amd64.deb'
end

dpkg_package 'cloudhsm-client' do
  source "#{installers_dir}/cloudhsm-client_latest_amd64.deb"
end

dpkg_package 'cloudhsm-client-pkcs11' do
  source "#{installers_dir}/cloudhsm-client-pkcs11_latest_amd64.deb"
end

apt_package 'libengine-pkcs11-openssl'
