
# Root directory for rbenv. Under this path, the `builds` subdirectory will
# contain ruby versions, and `shims` will contain the binstubs.
# The caller is expected to set RBENV_ROOT to this path in /etc/environment to
# set it globally and to add $RBENV_ROOT/shims/ to the global PATH.
default['identity-ruby']['rbenv_root'] = '/opt/ruby_build'

# Array of which ruby versions to install
default['identity-ruby']['ruby_versions'] = []

# Default ruby version (sets $RBENV_ROOT/version file)
default['identity-ruby']['default_ruby_version'] = nil
