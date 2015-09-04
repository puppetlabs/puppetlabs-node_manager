require File.expand_path(File.join(File.dirname(__FILE__), '..', 'rbac_api'))
require 'json'

Puppet::Type.type(:rbac_user).provide(:rbac_user, :parent => Puppet::Provider::Rbac_api) do

  # API will fail if disallowed-keys are passed
  # Decided to use override_environment instead
  def self.friendly_name
    {
      :id           => 'id',
      :login        => 'name',
      :email        => 'email',
      :display_name => 'display_name',
      :is_group     => 'group',
      :is_remote    => 'remote',
      :is_revoked   => 'revoked',
      :is_superuser => 'superuser',
      :last_login   => 'last_login',
      :role_ids     => 'role_ids',
      :password     => 'password'
    }
  end

  def self.instances
    rbacusers = JSON.parse(rest('GET', 'users', {'app' => 'rbac-api'}))
    rbacusers.collect do |user|
      rbacusers_hash = {}
      friendly_name.each do |property,friendly|
        rbacusers_hash[friendly.to_sym] = user[property.to_s]
      end
      rbacusers_hash[:ensure] = :present
      rbacusers_hash[:login]  = user['name'] unless user['login']
      new(rbacusers_hash)
    end
  end

  def self.prefetch(resources)
    rbacusers = instances
    resources.keys.each do |user|
      if provider = rbacusers.find{ |u| u.name == user }
        resources[user].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  mk_resource_methods

  def create
    # Only passing parameters that are given
    send_data = @resource.original_parameters
    # namevar may not be in this hash 
    send_data[:login]        = resource[:name] unless send_data[:login]
    # key changed for usability
    send_data[:remote]       = send_data[:is_remote] if send_data[:is_remote]
    # key changed for usability
    send_data[:superuser]    = send_data[:is_superuser] if send_data[:is_superuser]
    # Empty role_id is seen as false
    send_data[:role_ids]     = [] unless send_data[:role_ids]
    # Display name is required- fill in with login
    send_data[:display_name] = send_data[:login] unless send_data[:display_name]

    debug send_data
    friendlies = Puppet::Type::Rbac_user::ProviderRbac_user.friendly_name
    data = Helpers.data_hash(send_data, friendlies)
    puts data.inspect
    resp = Puppet::Type::Rbac_user::ProviderRbac_user.rest('POST', 'users', data)

    send_data.each_key do |k|
      @property_hash[k] = @resource[k]
    end

    exists? ? (return true) : (return false)
  end

  # DELETE method isn't available thru API yet
  #def destroy
  #  resp = Puppet::Provider::Nc_api.rest('DELETE', "groups/#{@property_hash[:id]}")
  #  @property_hash.clear
  #  exists? ? (return false) : (return true)
  #end

  friendly_name.each do |property,friendly|
    define_method "#{friendly}=" do |value|
      # All these fields are required
      send_data                = {}
      send_data[property]      = value
      send_data[:email]        = @property_hash[:email] || 'admin@host.com'
      send_data[:last_login]   = @property_hash[:last_login] || ''
      send_data[:is_revoked]   = @property_hash[:is_revoked] || false
      send_data[:is_remote]    = @property_hash[:is_remote] || false
      send_data[:is_superuser] = @property_hash[:is_superuser] || false
      send_data[:login]        = @property_hash[:login] || @property_hash[:name]
      send_data[:id]           = @property_hash[:id]
      send_data[:role_ids]     = @property_hash[:role_ids]
      send_data[:display_name] = @property_hash[:display_name]
      send_data[:is_group]     = @property_hash[:is_group] || false
      friendlies               = Puppet::Type::Rbac_user::ProviderRbac_user.friendly_name
      data                     = Helpers.data_hash(send_data, friendlies)
      Puppet::Provider::Rbac_api.rest('PUT', "users/#{@property_hash[:id]}", data) 
      @property_hash[property]  = @resource[friendly.to_sym]
    end
  end

end
