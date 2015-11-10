require 'puppet/util/node_groups'

module Puppet::Parser::Functions
  newfunction(:node_groups, :type => :rvalue) do |args|
    node_name = args[0]
    raise ArgumentError, 'Function accepts a single String' unless (
      args.length == 0 or
      ( args.length == 1 and node_name.is_a?(String) )
    )

    ng     = Puppet::Util::Node_groups.new
    groups = ng.groups.get_groups

    # When querying a specific group
    if args.length == 1
      # Assuming there is only one group by the name
      Puppet::Util::Node_groups.hashify_group_array(
        groups.select { |g| g['name'] == node_name }
      )
    else
      Puppet::Util::Node_groups.hashify_group_array(groups)
    end
  end
end
