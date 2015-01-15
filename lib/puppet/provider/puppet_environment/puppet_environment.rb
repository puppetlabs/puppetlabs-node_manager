require File.expand_path(File.join(File.dirname(__FILE__), '..', 'nc_api'))
require 'json'

Puppet::Type.type(:puppet_environment).provide(:puppet_environment, :parent => Puppet::Provider::Nc_api) do

  # API will fail if disallowed-keys are passed
  def self.friendly_name
    {
      :name => 'name',
    }
  end

  def self.instances
    env = JSON.parse(rest('GET', 'environments'))
    env.collect do |env|
      env_hash = {}
      friendly_name.each do |property,friendly|
        env_hash[friendly.to_sym] = env[property.to_s]
      end
      env_hash[:ensure] = :present
      new(env_hash)
    end
  end

  def self.prefetch(resources)
    env = instances
    resources.keys.each do |env|
      if provider = env.find{ |e| e.name == env }
        resources[env].provider = provider
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

    friendlies = Puppet::Type::Puppet_environment::Providerpuppet_environment.friendly_name
    data = Puppet::Provider::Nc_api.data_hash(send_data, friendlies)
    resp = Puppet::Provider::Nc_api.rest('PUT', 'environments')

    send_data.each_key do |k|
      @property_hash[k] = @resource[k]
    end

    exists? ? (return true) : (return false)
  end

  def destroy
    resp = Puppet::Provider::Nc_api.rest('DELETE', "environments/#{@property_hash[:name]}")
    @property_hash.clear
    exists? ? (return false) : (return true)
  end

end
