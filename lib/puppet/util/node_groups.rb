require 'puppetclassify'
require 'yaml'

class Puppet::Util::Node_groups < PuppetClassify
  attr_reader :groups
  alias_method :groups, :groups

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

    ng      = PuppetClassify.new(classifier_url, auth_info)
    @groups = ng.groups
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
end
