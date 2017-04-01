require 'json'

class Puppet::Util::Nc_https

  def initialize
    @ca_certificate_path = Puppet.settings['localcacert']
    @certificate_path    = Puppet.settings['hostcert']
    @private_key_path    = Puppet.settings['hostprivkey']

    begin
      nc_settings = YAML.load_file("#{Puppet.settings['confdir']}/classifier.yaml")
      nc_settings = nc_settings.first if nc_settings.class == Array            
    rescue
      fail "Could not find file #{Puppet.settings['confdir']}/classifier.yaml"
    else
      @classifier_url = "https://#{nc_settings['server']}:#{nc_settings['port']}/classifier-api"
    end
  end

  def get_groups
    res = do_https('v1/groups', 'GET')
    if res.code.to_i != 200
      Puppet.debug("Response code: #{res.code}")
      Puppet.debug("Response message: #{res.body}")
      fail('Unable to get node_group list')
    else
      JSON.parse(res.body)
    end
  end

  def create_group(data)
    endpoint = data.has_key?('id') ? "v1/groups/#{data['id']}" : 'v1/groups'
    res = do_https(endpoint, 'POST', data)
    if res.code.to_i != 303
      Puppet.debug("Response code: #{res.code}")
      Puppet.debug("Response message: #{res.body}")
      fail("Unable to create node_group '#{data['name']}'")
    else
      new_UID = res['location'].split('/')[-1]
      Puppet.notice("New node_group '#{data['name']}' with ID '#{new_UID}'")
      new_UID
    end
  end

  def delete_group(id)
    res = do_https("v1/groups/#{id}", 'DELETE')
    if res.code.to_i != 204
      Puppet.debug("Response code: #{res.code}")
      Puppet.debug("Response message: #{res.body}")
      fail("Unable to delete node_group '#{data['name']}'")
    else
      true
    end
  end

  def update_group(data)
    res = do_https("v1/groups/#{data['id']}", 'POST', data)
    if res.code.to_i != 200
      Puppet.debug("Response code: #{res.code}")
      Puppet.debug("Response message: #{res.body}")
      fail("Unable to update node_group '#{data['name']}'")
    else
      true
    end
  end

  private

  def do_https(endpoint, method = 'post', data = {})
    url  = "#{@classifier_url}/#{endpoint}"
    uri  = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)

    if uri.scheme == 'https'
      http.use_ssl     = true
      http.cert        = OpenSSL::X509::Certificate.new(File.read @certificate_path)
      http.key         = OpenSSL::PKey::RSA.new(File.read @private_key_path)
      http.ca_file     = @ca_certificate_path
      http.verify_mode = OpenSSL::SSL::VERIFY_CLIENT_ONCE
    end

    req              = Object.const_get("Net::HTTP::#{method.capitalize}").new(uri.request_uri)
    req.body         = data.to_json
    req.content_type = 'application/json'

    begin
      res = http.request(req)
    rescue Exception => e
      fail(e.message)
      debug(e.backtrace.inspect)
    else
      res
    end
  end

end
