Puppet::Type.newtype(:rbac_user) do
  id_format = /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
  desc 'The rbac_user type creates and manages Console users for the PE Console'
  ensurable
  newparam(:login, :namevar => true) do
    desc 'This is the login name for the rbac user'
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
  newproperty(:email) do
    desc 'An email address string'
    validate do |value|
      fail("#{email} is not a email address") unless value =~ /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/
    end
  end
  newparam(:display_name) do
    desc 'This is the string name for the rbac user'
    validate do |value|
      fail("#{name} is not a valid group name") unless value =~ /^[a-zA-Z0-9\-\_'\s]+$/
    end
  end
  newproperty(:password) do
    desc 'The user\'s password'
    validate do |value|
      fail("#{name} is not a valid group name") unless value =~ /^[a-zA-Z0-9\-\_'\s]+$/
    end
  end
  newproperty(:remote) do
    desc ''
    newvalues(:false, :true)
    defaultto :false
  end
  newproperty(:superuser) do
    desc ''
    newvalues(:false, :true)
    defaultto :false
  end
  newproperty(:is_revoked) do
    desc 'If the user needs a password reset token (read-only)'
    newvalues(:false, :true)
    validate do |value|
      fail("Is_revoked is read-only")
    end
  end
  newproperty(:last_login) do
    desc 'Indicating when the user last logged in (read-only)'
    validate do |value|
      fail("Last_login is read-only")
    end
  end
  newproperty(:role_ids) do
    desc 'An array of role IDs indicating which roles a remote user inherits from their groups (read-only)'
    validate do |value|
      fail("Inherited_role_ids is read-only")
    end
    defaultto []
  end
  newproperty(:group_ids) do
    desc 'An array of UUIDs indicating which groups a remote user inherits roles from (read-only)'
    validate do |value|
      fail("Group_ids is read-only")
    end
  end
end
