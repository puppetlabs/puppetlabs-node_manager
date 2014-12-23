Puppet::Type.newtype(:node_group) do
  desc 'The node_group type creates and managed node groups for the PE NC'
  ensurable
  newparam(:name, :namevar => true) do
    desc 'This is the common name for the node group'
    validate do |value|
      fail("#{name} is not a valid group name") unless value =~ /^[a-zA-Z0-9\-\_'\s]+$/
    end
  end
  newproperty(:id) do
    desc 'The ID of the group'
    validate do |value|
      fail("ID should be numbers and dashes") unless value =~ /^[a-z0-9\-]+$/
    end
  end
end
