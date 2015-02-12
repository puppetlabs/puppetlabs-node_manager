Puppet::Type.newtype(:rbac_group) do
  id_format = /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
  desc 'The rbac_group type creates and manages Console groups for the PE Console'
  ensurable
  newparam(:login, :namevar => true) do
    desc 'This is the login name for the rbac group'
    validate do |value|
      fail("#{name} is not a valid login") unless value =~ /^[a-zA-Z0-9\-\_'\.\s]+$/
    end
  end
  newproperty(:id) do
    desc 'The ID of the group'
    validate do |value|
      fail("ID is read-only")
    end
  end
  newparam(:display_name) do
    desc 'This is the string name for the rbac group'
    validate do |value|
      fail("#{name} is not a valid group name") unless value =~ /^[a-zA-Z0-9\-\_'\s]+$/
    end
  end
  newproperty(:remote) do
    desc ''
    newvalues(:false, :true)
    defaultto :false
  end
  newproperty(:user_ids) do
    desc 'Array of user IDs that inherit from this group'
    validate do |value|
      fail("User IDs must be supplied as an array") unless value.is_a?(Array)
    end
    defaultto []
  end
end
