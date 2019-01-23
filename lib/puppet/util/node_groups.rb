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

  def initialize
    auth_info = {
      "ca_certificate_path" => Puppet.settings['localcacert'],
      "certificate_path"    => Puppet.settings['hostcert'],
      "private_key_path"    => Puppet.settings['hostprivkey'],
    }

    classifier_yaml = [
      File.join(Puppet.settings['confdir'], 'classifier.yaml'),
      '/etc/puppetlabs/puppet/classifier.yaml',
    ].find { |file| File.exist?(file) }

    fail "node_manager: could not find classifier.yaml" if classifier_yaml.nil?

    begin
      nc_settings = YAML.load_file(classifier_yaml)
      nc_settings = nc_settings.first if nc_settings.class == Array
    rescue
      fail "Could not load file #{classifier_yaml}"
    else
      classifier_url = "https://#{nc_settings['server']}:#{nc_settings['port']}/classifier-api"
    end

    super(classifier_url, auth_info)
  end

  # puppetclassify does not currently have a
  # method to delete environments.  Using this
  # in the meantime.
  def delete_environment(name)
    env_res = @puppet_https.delete("#{@nc_api_url}/v1/environments/#{name}")

    unless env_res.code.to_i == 204
      STDERR.puts "An error occured saving the environment: HTTP #{env_res.code} #{env_res.message}"
      STDERR.puts env_res.body
    end
  end
end
