require File.expand_path(File.join(File.dirname(__FILE__), '..', 'nc_api'))
require 'json'

Puppet::Type.type(:node_group).provide(:node_group, :parent => Puppet::Provider::Nc_api) do

  # API will fail if disallowed-keys are passed
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
    ngs = JSON.parse(rest('GET', 'groups'))
    ngs.collect do |group|
      ngs_hash = {}
      friendly_name.each do |property,friendly|
        ngs_hash[friendly.to_sym] = group[property.to_s]
      end
      ngs_hash[:ensure] = :present
      binding.pry
      new(ngs_hash)
      #new(
      #  :classes              => group['classes'],
      #  :ensure               => :present,
      #  :environment          => group['environment'],
      #  :override_environment => group['environment_trumps'].to_s,
      #  :id                   => group['id'],
      #  :name                 => group['name'],
      #  :parent               => group['parent'],
      #  :rule                 => group['rule'],
      #  :variables            => group['variables']
      #)
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
    # Passing an empty hash results in undef
    send_data[:classes] = {} unless send_data[:classes]

    data = self.data_hash(send_data)
    resp = Puppet::Provider::Nc_api.rest('POST', 'groups', data)

    @property_hash[:classes]              = @resource[:classes]
    @property_hash[:ensure]               = :present
    @property_hash[:environment]          = @resource[:environment]
    @property_hash[:id]                   = @resource[:id]
    @property_hash[:name]                 = @resource[:name]
    @property_hash[:override_environment] = @resource[:override_environment]
    @property_hash[:parent]               = @resource[:parent]
    @property_hash[:rule]                 = @resource[:rule]
    @property_hash[:variables]            = @resource[:variables]

    exists? ? (return true) : (return false)
  end

  def destroy
    resp = Puppet::Provider::Nc_api.rest('DELETE', "groups/#{@resource[:id]}")

    @property_hash.clear
    exists? ? (return false) : (return true)
  end

  def data_hash(param_hash)
    #filter_keys = [
    #  :classes,
    #  :environment,
    #  :id,
    #  :name,
    #  :override_environment,
    #  :parent,
    #  :rule,
    #  :variables
    #]

    # Construct JSON string, not JSON object
    data = '{ '
    param_hash.each do |k,v|
      if self.friendly_name.include? k
        data += "\"#{k}\": "
        data += v.is_a?(String) ? "\"#{v}\"," : "#{v},"
      end
    end
    data = data.gsub(/^(.*),/, '\1 }')
    debug data
    data
  end

end
