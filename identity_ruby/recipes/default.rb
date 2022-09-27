
# Use rbenv root directory from attributes
rbenv_root = node.fetch('identity_ruby').fetch('rbenv_root')

# Set RBENV_ROOT env variable for this chef run. The recipe caller is expected
# to set RBENV_ROOT in /etc/environment and to add $RBENV_ROOT/shims to PATH.
ENV['RBENV_ROOT'] = rbenv_root

# install rbenv version from apt
package 'rbenv' do
  retries 12
  retry_delay 5
end


# specify bundler version
bundler_version = node.fetch('identity_ruby').fetch('bundler_version')

#install ruby-build
execute 'install ruby-build' do
  command 'git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build'
end

node.fetch('identity_ruby').fetch('ruby_versions').each do |version|
  execute "install ruby version #{version}" do
    command "rbenv install #{version}"
    notifies :run, 'execute[rbenv rehash]'
  end

  # if version follow standard x.x.x version number, create alias at x.x so
  # that .ruby-version files don't need to specify patch release
  if version =~ /\A\d+\.\d+\.\d+\z/
    short_name = version.split('.')[0..1].join('.')
    link "#{rbenv_root}/versions/#{short_name}" do
      to "#{rbenv_root}/versions/#{version}"
    end
  end

  #install bundler_version of bundler
  execute "install bundler #{bundler_version} for rbenv #{version}" do
    command "rbenv exec gem install bundler:#{bundler_version}"
    environment({
      'RBENV_ROOT' => rbenv_root,
      'RBENV_VERSION' => version
    })
  end
end

# set default rbenv ruby version if provided
if node.fetch('identity_ruby')['default_ruby_version']
  file "#{rbenv_root}/version" do
    content node.fetch('identity_ruby').fetch('default_ruby_version') + "\n"
  end
end

# rebuild shims
execute 'rbenv rehash' do
  environment({
    'RBENV_ROOT' => rbenv_root
  })
end
