class Puppet::Provider::Nc_api < Puppet::Provider
require 'yaml'
require 'net/http'
require 'openssl'
   
  def self.rest(method, endpoint, data=false)

    begin
      nc_settings    = YAML.load_file("#{Puppet.settings['confdir']}/classifier.yaml")
    rescue
      fail "Could not find file #{Puppet.settings['confdir']}/classifier.yaml"
    end
    rest_endpoint    = "#{nc_settings['prefix']}/v1/#{endpoint}"
    http             = Net::HTTP.new(nc_settings['server'], nc_settings['port'])
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.cert        = OpenSSL::X509::Certificate.new(File.read(Puppet.settings['hostcert']))
    http.key         = OpenSSL::PKey::RSA.new(File.read(Puppet.settings['hostprivkey']))
    http.ca_file     = Puppet.settings['localcacert']

    case method
    when 'GET'
      req      = Net::HTTP::Get.new(rest_endpoint)
    when 'POST'
      req      = Net::HTTP::Post.new(rest_endpoint)
      req.body = data
    when 'PUT'
      req      = Net::HTTP::Put.new(rest_endpoint)
      req.body = data
    when 'DELETE'
      req      = Net::HTTP::Delete.new(rest_endpoint)
    else
      fail "#{method} is not a supported method."
    end

    req['Content-Type'] = 'application/json'
    resp                = http.request(req)

    debug "Response code #{resp.code}"

    case resp.code
    when '200','204'
      resp.body
    when '201'
      info "New environment created as #{resp.body}"
      resp.body
    when '303'
      info "Added #{resp['Location']} to #{endpoint}"
      resp.body 
    when '422'
      jresp = JSON.parse(resp.body)
      debug_message = "#{jresp['kind']}: "
      jresp['details'].each do |k,detail|
        debug_message += "#{k}: #{value} "
      end
      debug debug_message
      fail jresp['kind']
    else
      fail "#{resp.code}: #{resp.message}\n#{resp.body}"
      jresp = JSON.parse(resp.body)
      debug jresp['kind']
    end
  end

  def self.data_hash(param_hash, filter=false)
    # Construct JSON string, not JSON object
    data = '{ '
    param_hash.each do |k,v|
      if !filter or filter.include? k
        data += "\"#{k}\": "
        if v.is_a?(String)
          data += "\"#{v}\","
        elsif v.is_a?(Hash)
          data += v.to_s.gsub(/=>/, ':')
          data += ','
        else
          data += "#{v},"
        end
      end
    end
    data = data.gsub(/^(.*),/, '\1 }')
    debug data
    data
  end

end
