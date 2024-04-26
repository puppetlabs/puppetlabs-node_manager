#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'

# Need to append LOAD_PATH
Puppet.initialize_settings
$:.unshift(Puppet[:plugindest])

require 'puppet/util/nc_https'
require 'puppet_x/node_manager/common'


def update_classes(env)
  nc = Puppet::Util::Nc_https.new
  nc.update_classes(env)
end

params = JSON.parse(STDIN.read)
env    = params['env'] || 'production'

begin
  res = update_classes(env)
  if res.is_a?(Hash)
    puts({ responsecode: res.code, responsebody: res.body }.to_json)
  else
    puts({ responsecode: 201, responsebody: %(#{env} update-classes triggered) }.to_json)
  end
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
