require 'puppet/util/node_groups'

Puppet::Type.type(:puppet_environment).provide(:puppetclassify) do
  confine :feature => :puppetclassify

  def initialize(value={})
    super(value)
  end

  def self.classifier
    @classifier ||= initialize_client
  end

  def self.initialize_client
    Puppet::Util::Node_groups.new
  end
  # API will fail if disallowed-keys are passed
  def self.friendly_name
    {
      :name => 'name',
    }
  end

  def self.instances
    ngs = classifier.environments.get_environments
    ngs.collect do |env|
      ngs_hash = {}
      friendly_name.each do |property,friendly|
        ngs_hash[friendly.to_sym] = env[property.to_s]
      end
      ngs_hash[:ensure] = :present
      new(ngs_hash)
    end
  end

  def self.prefetch(resources)
    ngs = instances
    resources.keys.each do |env|
      if provider = ngs.find{ |g| g.name == env }
        resources[env].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  mk_resource_methods

  def create
    resp = self.class.classifier.environments.create_environment(@resource[:name])
    # create_environment method doesn't have output
    # from puppetclassify method.  Only outputs if
    # there is an error.
    unless resp
      @resource.original_parameters.each_key do |k|
        if k == :ensure
          @property_hash[:ensure] = :present
        else
          @property_hash[k]       = @resource[k]
        end
      end
    else
      fail("puppetclassify was not able to create environment")
    end

    exists? ? (return true) : (return false)

  end

  def destroy
    begin
      self.class.classifier.delete_environment(@property_hash[:name])
    rescue Exception => e
      fail(e.message)
      debug(e.backtrace.inspect)
    else
      @property_hash.clear
    end
    exists? ? (return false) : (return true)
  end
end
