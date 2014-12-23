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

end
