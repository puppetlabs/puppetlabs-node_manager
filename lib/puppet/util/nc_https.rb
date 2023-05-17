require 'json'

class Puppet::Util::Nc_https
  def initialize
    settings_file = if File.exist?("#{Puppet.settings['confdir']}/node_manager.yaml")
                      "#{Puppet.settings['confdir']}/node_manager.yaml"
                    else
                      "#{Puppet.settings['confdir']}/classifier.yaml"
                    end

    begin
      nc_settings = YAML.load_file(settings_file)
      nc_settings = nc_settings.first if nc_settings.class == Array
    rescue
      raise "Could not find file #{settings_file}"
    else
      cl_server       = nc_settings['server'] || Puppet.settings['server']
      cl_port         = nc_settings['port']   || 4433
      @classifier_url = "https://#{cl_server}:#{cl_port}/classifier-api"
      @token          = nc_settings['token']
      unless cl_server == Puppet.settings['certname']
        remote_client = "#{Facter.value('fqdn')} (#{Facter.value('ipaddress')})"
        Puppet.debug("Managing node_group remotely from #{remote_client}")
      end
      Puppet.debug("classifier_url: #{@classifier_url}")

      unless @token && !@token.empty?
        @ca_certificate_path = nc_settings['localcacert'] || Puppet.settings['localcacert']
        @certificate_path    = nc_settings['hostcert']    || Puppet.settings['hostcert']
        @private_key_path    = nc_settings['hostprivkey'] || Puppet.settings['hostprivkey']
      end
    end
  end

  def get_groups
    res = do_https('v1/groups', 'GET')
    if res.code.to_i != 200
      error_msg(res)
      raise('Unable to get node_group list')
    else
      JSON.parse(res.body)
    end
  end

  def create_group(data)
    endpoint = data.has_key?('id') ? "v1/groups/#{data['id']}" : 'v1/groups'
    res = do_https(endpoint, 'POST', data)
    if res.code.to_i != 303
      error_msg(res)
      raise("Unable to create node_group '#{data['name']}'")
    else
      new_UID = res['location'].split('/')[-1]
      Puppet.notice("New node_group '#{data['name']}' with ID '#{new_UID}'")
      new_UID
    end
  end

  def delete_group(id)
    res = do_https("v1/groups/#{id}", 'DELETE')
    if res.code.to_i != 204
      error_msg(res)
      raise("Unable to delete node_group '#{data['name']}'")
    else
      true
    end
  end

  def update_group(data)
    # ISSUE 26
    # Add nil for empty rules
    data = Hash[data.map { |k, v| v == [''] ? [k, nil] : [k, v] }]

    res = do_https("v1/groups/#{data['id']}", 'POST', data)
    if res.code.to_i != 200
      error_msg(res)
      raise("Unable to update node_group '#{data['name']}'")
    else
      true
    end
  end

  def import_hierarchy(data)
    res = do_https('v1/import-hierarchy', 'POST', data)
    if res.code.to_i != 204
      error_msg(res)
      raise('Unable to import node_groups')
    else
      true
    end
  end

  def get_classes(env = false, name = false)
    url_array = ['v1']
    url_array << 'classes' unless env
    url_array << "environments/#{env}/classes" if env
    url_array << name if name
    res = do_https(url_array.join('/'), 'GET')
    if res.code.to_i != 200
      error_msg(res)
      raise JSON.parse(res.body)['msg']
    else
      JSON.parse(res.body)
    end
  end

  def update_classes(env = nil)
    url_array = ['v1/update-classes']
    url_array << "?environment=#{env}" if env
    res = do_https(url_array.join(''), 'POST')
    if res.code.to_i != 201
      error_msg(res)
      raise('Unable to update classes')
    else
      true
    end
  end

  def get_classified(name, expl = false, facts = {}, trusted = {})
    url_array = ['v1/classified/nodes']
    url_array << name
    url_array << 'explanation' if expl
    data = facts.merge(trusted)
    res  = do_https(url_array.join('/'), 'POST', data)
    if res.code.to_i != 200
      error_msg(res)
    else
      JSON.parse(res.body)
    end
  end

  def pin_node(node, group_id)
    data = { 'nodes' => [node], }
    res  = do_https("v1/groups/#{group_id}/pin", 'POST', data)
    if res.code.to_i != 204
      error_msg(res)
    else
      (JSON.parse(res.body) if res.body) || true
    end
  end

  def unpin_node(node, group_id)
    data = { 'nodes' => [node], }
    res  = do_https("v1/groups/#{group_id}/unpin", 'POST', data)
    if res.code.to_i != 204
      error_msg(res)
    else
      (JSON.parse(res.body) if res.body) || true
    end
  end

  def unpin_from_all(node)
    data = { 'nodes' => [node] }
    res  = do_https('v1/commands/unpin-from-all', 'POST', data)
    if res.code.to_i != 200
      error_msg(res)
    else
      (JSON.parse(res.body) if res.body) || true
    end
  end

  def get_environments
    res = do_https('v1/environments', 'GET')
    JSON.parse(res.body)
  end

  def get_nodes(name)
    url_array = [ 'v1/nodes' ]
    url_array << name if name
    res = do_https(url_array.join('/'), 'GET')
    if res.code.to_i != 200
      error_msg(res)
      raise('Unable to get nodes history')
    else
      JSON.parse(res.body)
    end
  end

  private

  def do_https(endpoint, method = 'post', data = {})
    url  = "#{@classifier_url}/#{endpoint}"
    uri  = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)

    if @token && !@token.empty?
      Puppet.debug('Using token authentication')
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    else
      Puppet.debug('Using SSL authentication')
      http.use_ssl     = true
      http.cert        = OpenSSL::X509::Certificate.new(File.read(@certificate_path))
      http.key         = OpenSSL::PKey::RSA.new(File.read(@private_key_path))
      http.ca_file     = @ca_certificate_path
      http.verify_mode = OpenSSL::SSL::VERIFY_CLIENT_ONCE
    end

    req              = Net::HTTP.const_get(method.capitalize).new(uri.request_uri)
    req.body         = data.to_json
    req.content_type = 'application/json'

    # If using token
    req['X-Authentication'] = @token if @token

    begin
      res = http.request(req)
    rescue Exception => e
      raise(e.message)
      debug(e.backtrace.inspect)
    else
      res
    end
  end

  def error_msg(res)
    json = JSON.parse(res.body)
    kind = json['kind']
    msg  = json['msg']
    Puppet.err %(node_manager failed with error type '#{kind}': #{msg})
    Puppet.debug("Response code: #{res.code}")
    Puppet.debug("Response message: #{res.body}")
  end
end
