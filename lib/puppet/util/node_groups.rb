# The provider is loaded both by the master and by the agent. Only the agent
# will actually need the puppetclassify gem and methods. In order to allow
# seamless loading by the masteror during compilation prior to enforcing state,
# allow graceful failure when unable to load puppetclassify.

begin
  require 'yaml'
  require 'puppetclassify'
  parent = PuppetClassify
rescue LoadError => e
  parent = Object
end

class Puppet::Util::Node_groups < parent
  attr_reader :groups, :environments
  alias_method :groups, :groups
  alias_method :environments, :environments

  def initialize
    auth_info = {
      "ca_certificate_path" => Puppet.settings['localcacert'],
      "certificate_path"    => Puppet.settings['hostcert'],
      "private_key_path"    => Puppet.settings['hostprivkey'],
    }

    begin
      nc_settings = YAML.load_file("#{Puppet.settings['confdir']}/classifier.yaml")
    rescue
      fail "Could not find file #{Puppet.settings['confdir']}/classifier.yaml"
    else
      classifier_url = "https://#{nc_settings['server']}:#{nc_settings['port']}/classifier-api"
    end

    ng            = PuppetClassify.new(classifier_url, auth_info)
    @groups       = ng.groups
    @environments = ng.environments

    # Add in for delete_environment method.
    # See below.
    @auth_info    = auth_info
    @nc_api_url   = classifier_url
  end

  # Transform the node group array in to a hash
  # with a key of the name and an attribute
  # hash of the rest.
  def self.hashify_group_array(group_array)
    hashified = Hash.new

    group_array.each do |group|
      hashified[group['name']] = group
    end

    hashified
  end

  # puppetclassify does not currently have a
  # method to delete environments.  Using this
  # in the meantime.
  def delete_environment(name)
    puppet_https = PuppetHttps.new(@auth_info)
    env_res = puppet_https.delete("#{@nc_api_url}/v1/environments/#{name}")

    unless env_res.code.to_i == 204
      STDERR.puts "An error occured saving the environment: HTTP #{env_res.code} #{env_res.message}"
      STDERR.puts env_res.body
    end
  end
end
