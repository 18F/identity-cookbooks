# Root directory for rbenv. 
# The caller is expected to set RBENV_ROOT to this path in /etc/environment to
# set it globally and to add $RBENV_ROOT/shims/ to the global PATH.
default['identity_ruby']['rbenv_root'] = '/opt/ruby_build'
default['identity_ruby']['bundler_version'] = nil

# Array of which ruby versions to install
default['identity_ruby']['ruby_versions'] = []

# Default ruby version (sets $RBENV_ROOT/version file)
default['identity_ruby']['default_ruby_version'] = nil
