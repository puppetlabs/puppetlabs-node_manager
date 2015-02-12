require File.expand_path(File.join(File.dirname(__FILE__), '..', 'nc_api'))
require 'json'
require 'puppet/provider/helpers'
require 'pry'

Puppet::Type.type(:node_group).provide(:node_group, :parent => Puppet::Provider::Nc_api) do

  $ngs = []

  # API will fail if disallowed-keys are passed
  # Decided to use override_environment instead
  def self.friendly_name
    {
      :classes            => 'classes',
      :environment        => 'environment',
      :environment_trumps => 'override_environment',
      :id                 => 'id',
      :name               => 'name',
      :parent             => 'parent',
      :rule               => 'rule',
      :variables          => 'variables'
    }
  end

  def self.instances
    $ngs = JSON.parse(rest('GET', 'groups'))
    $ngs.collect do |group|
      ngs_hash = {}
      friendly_name.each do |property,friendly|
        # Replace parent ID with string name
        if friendly == 'parent'
          gindex = $ngs.index { |i| i['id'] == group[property.to_s] }
          ngs_hash[friendly.to_sym] = $ngs[gindex]['name']
        else
          ngs_hash[friendly.to_sym] = group[property.to_s]
        end
      end
      ngs_hash[:ensure] = :present
      new(ngs_hash)
    end
  end

  def self.prefetch(resources)
    ngs = instances
    resources.keys.each do |group|
      if provider = ngs.find{ |g| g.name == group }
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
    send_data[:name] = resource[:name] unless send_data[:name]
    # key changed for usability
    send_data[:override_environment] = send_data[:environment_trumps] if send_data[:environment_trumps]
    # Passing an empty hash in the type results in undef
    send_data[:classes] = {} unless send_data[:classes]

    binding.pry
    if send_data[:parent].is_a?(String)
      gindex = $ngs.index { |i| i['name'] == send_data[:parent] }
      send_data[:parent] = $ngs[gindex]['id']
    end

    friendlies = Puppet::Type::Node_group::ProviderNode_group.friendly_name
    data = Helpers.data_hash(send_data, friendlies)
    resp = Puppet::Provider::Nc_api.rest('POST', 'groups', data)

    send_data.each_key do |k|
      @property_hash[k] = @resource[k]
    end

    exists? ? (return true) : (return false)
  end

  def destroy
    resp = Puppet::Provider::Nc_api.rest('DELETE', "groups/#{@property_hash[:id]}")
    @property_hash.clear
    exists? ? (return false) : (return true)
  end

  friendly_name.each do |property,friendly|
    define_method "#{friendly}=" do |value|
      send_data = {}
      send_data[property] = value
      friendlies = Puppet::Type::Node_group::ProviderNode_group.friendly_name
      data = Helpers.data_hash(send_data, friendlies)
      Puppet::Provider::Nc_api.rest('POST', "groups/#{@property_hash[:id]}", data) 
      @property_hash[property] = @resource[friendly.to_sym]
    end
  end

end
