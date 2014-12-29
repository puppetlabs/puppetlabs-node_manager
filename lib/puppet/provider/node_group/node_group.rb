require File.expand_path(File.join(File.dirname(__FILE__), '..', 'nc_api'))
require 'json'
require 'pry'

Puppet::Type.type(:node_group).provide(:node_group, :parent => Puppet::Provider::Nc_api) do

  def self.instances
    ngs = JSON.parse(rest('GET', 'groups'))
    ngs.collect do |group|
      new(
        :name                 => group['name'],
        :ensure               => :present,
        :id                   => group['id'],
        :override_environment => group['environment_trumps'],
        :parent               => group['parent'],
        :rule                 => group['rule'],
        :variables            => group['variables'],
        :environment          => group['environment'],
        :classes              => group['classes']
      )
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
    data = self.data_hash(@resource.original_parameters)
    resp = Puppet::Provider::Nc_api.rest('POST', 'groups', data)
    exists? ? (return true) : (return false)
  end

  def data_hash(param_hash)
    # API will fail if disallowed-keys are passed
    filter_keys = [
      :classes,
      :environment,
      :environment_override,
      :id,
      :name,
      :parent,
      :rule,
      :variables
    ]
    # namevar may not be in this hash 
    param_hash[:name] = resource[:name] unless param_hash[:name]
    # key changed for usability
    param_hash[:environment_override] = param_hash[:environment_trumps] if param_hash[:environment_trumps]
    # Passing an empty hash results in undef
    param_hash[:classes] = {} unless param_hash[:classes]

    # Construct JSON string, not JSON object
    data = '{ '
    binding.pry
    param_hash.each do |k,v|
      if filter_keys.include? k
        data += "\"#{k}\": "
        data += v.is_a?(String) ? "\"#{v}\"," : "#{v},"
      end
    end
    data = data.gsub(/^(.*),/, '\1 }')
    debug data
    data
  end

end
