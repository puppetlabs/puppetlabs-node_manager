require File.expand_path(File.join(File.dirname(__FILE__), '..', 'rbac_api'))
require 'json'
require 'pry'

Puppet::Type.type(:rbac_group).provide(:rbac_group, :parent => Puppet::Provider::Rbac_api) do

  # API will fail if disallowed-keys are passed
  # Decided to use override_environment instead
  def self.friendly_name
    {
      :id           => 'id',
      :login        => 'name',
      :display_name => 'display_name',
      :is_remote    => 'remote',
      :user_ids     => 'user_ids',
    }
  end

  def self.instances
    rbacgroups = JSON.parse(rest('GET', 'groups', {'app' => 'rbac-api'}))
    rbacgroups.collect do |group|
      rbacgroups_hash = {}
      friendly_name.each do |property,friendly|
        rbacgroups_hash[friendly.to_sym] = group[property.to_s]
      end
      rbacgroups_hash[:ensure] = :present
      new(rbacgroups_hash)
    end
  end

  def self.prefetch(resources)
    rbacgroups = instances
    resources.keys.each do |group|
      if provider = rbacgroups.find{ |g| g.name == group }
        resources[group].provider = provider
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
    send_data[:user_ids]     = [] unless send_data[:user_ids]
    # Display name is required- fill in with login
    send_data[:display_name] = send_data[:login] unless send_data[:display_name]

    debug send_data
    friendlies = Puppet::Type::Rbac_group::ProviderRbac_group.friendly_name
    data = Helpers.data_hash(send_data, friendlies)
    binding.pry
    resp = Puppet::Type::Rbac_group::ProviderRbac_group.rest('POST', 'groups', data)

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
      send_data = {}
      send_data[property] = value
      friendlies = Puppet::Type::Rbac_group::ProviderRbac_group.friendly_name
      data = Helpers.data_hash(send_data, friendlies)
      Puppet::Provider::Rbac_api.rest('POST', "groups/#{@property_hash[:id]}", data) 
      @property_hash[property] = @resource[friendly.to_sym]
    end
  end

end
