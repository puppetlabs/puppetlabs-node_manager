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
      fail("ID should be numbers and dashes") unless value =~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
    end
  end
  newproperty(:override_environment) do
    desc 'Override parent environments'
    defaultto :false
    newvalues(:false, :true)
  end
  newproperty(:parent) do
    desc 'The ID of the parent group'
    validate do |value|
      fail("ID should be numbers and dashes") unless value =~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
    end
  end
  newproperty(:variables) do
    desc 'Variables set this group\'s scope'
    validate do |value|
      fail("Variables must be supplied as a hash") unless value.is_a?(Hash)
    end
  end
  newproperty(:rule) do
    desc 'Match conditions for this group'
    validate do |value|
      fail("Rules must be supplied as a hash") unless value.is_a?(Hash)
    end
  end
  newproperty(:environment) do
    desc 'Environment for this group'
    validate do |value|
      fail("Invalid environment name") unless value =~ /^[a-z][a-z0-9]+$/
    end
  end
  newproperty(:classes) do
    desc 'Classes applied to this group'
    validate do |value|
      fail("Classes must be supplied as a hash") unless value.is_a?(Hash)
    end
  end
end
