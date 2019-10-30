
# Use rbenv root directory from attributes
rbenv_root = node.fetch('identity_ruby').fetch('rbenv_root')

# Set RBENV_ROOT env variable for this chef run. The recipe caller is expected
# to set RBENV_ROOT in /etc/environment and to add $RBENV_ROOT/shims to PATH.
ENV['RBENV_ROOT'] = rbenv_root

# install rbenv version from apt
package 'rbenv'

include_recipe 'ruby_build'

# Set up rbenv with specified directory as RBENV_ROOT, using rubies installed by
# ruby-build under $RBENV_ROOT/builds/.
directory rbenv_root
directory "#{rbenv_root}/shims"
link "#{rbenv_root}/versions" do
  to '/opt/ruby_build/builds'
end

cache_dir = node.fetch('login_dot_gov').fetch('cache_dir')
openssl_srcpath = "#{cache_dir}/openssl-#{node.fetch('login_dot_gov').fetch('openssl').fetch('version')}"
# We would use RUBY_CONFIGURE_OPTS except for
# https://github.com/poise/poise-ruby-build/issues/9

ENV['RUBY_CONFIGURE_OPTS'] = "--with-openssl-dir=#{openssl_srcpath}"

  
node.fetch('identity_ruby').fetch('ruby_versions').each do |version|
  ruby_build_ruby version do
    prefix_path "#{rbenv_root}/builds/#{version}"
    notifies :run, 'execute[rbenv rehash]'
  end

  # if version follow standard x.x.x version number, create alias at x.x so
  # that .ruby-version files don't need to specify patch release
  if version =~ /\A\d+\.\d+\.\d+\z/
    short_name = version.split('.')[0..1].join('.')
    link "#{rbenv_root}/builds/#{short_name}" do
      to "#{rbenv_root}/builds/#{version}"
    end
  end

  #install current version of bundler 2.0
  execute "install current bundler for rbenv #{version}" do
    command %w[rbenv exec gem install bundler]
    environment({
      'RBENV_ROOT' => rbenv_root,
      'RBENV_VERSION' => version
    })
  end

  # Backwards compatibility for bundler 1.x
  # This can be removed once all login.gov apps are using Bundler 2.0
  # Install bundler 1.x in addition to whatever comes with rbenv
  execute "install bundler 1.x for rbenv #{version}" do
    command %w[rbenv exec gem install bundler -v] + ['~> 1.17']
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
