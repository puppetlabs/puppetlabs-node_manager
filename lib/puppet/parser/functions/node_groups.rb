begin
  require 'puppet/util/nc_https'
  require 'puppet_x/node_manager/common'
rescue LoadError
  mod = Puppet::Module.find('node_manager', Puppet[:environment].to_s)
  require File.join mod.path, 'lib/puppet/util/nc_https'
  require File.join mod.path, 'lib/puppet_x/node_manager/common'
end

module Puppet::Parser::Functions
  newfunction(:node_groups, :type => :rvalue) do |args|
    node_name = args[0]
    raise ArgumentError, 'Function accepts a single String' unless (
      args.length == 0 or
      ( args.length == 1 and node_name.is_a?(String) )
    )

    ng     = Puppet::Util::Nc_https.new
    groups = ng.get_groups

    # When querying a specific group
    if args.length == 1
      # Assuming there is only one group by the name
      PuppetX::Node_manager::Common.hashify_group_array(
        groups.select { |g| g['name'] == node_name }
      )
    else
      PuppetX::Node_manager::Common.hashify_group_array(groups)
    end
  end
end
