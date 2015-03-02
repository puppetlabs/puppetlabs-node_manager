class Helpers
require 'yaml'
require 'net/http'
require 'openssl'
require 'pry'
   
  def self.rest_helper(method, endpoint, args={})

    app  = args['app']  ? args['app']  : 'classifier-api'
    data = args['data'] ? args['data'] : false
    v    = args['v']    ? args['v']    : 'v1'

    case app
    when 'classifier-api'
      begin
        nc_settings = YAML.load_file("#{Puppet.settings['confdir']}/classifier.yaml")
      rescue
        fail "Could not find file #{Puppet.settings['confdir']}/classifier.yaml"
      else
        server = nc_settings['server']
        port   = nc_settings['port']
      end
    when 'rbac-api'
      server = 'puppet'
      port   = '4433'
    end

    rest_endpoint    = "/#{app}/#{v}/#{endpoint}"
    Puppet.debug(rest_endpoint)
    http             = Net::HTTP.new(server, port)
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
    Puppet.debug "Response code #{resp.code}"

    resp

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
    Puppet.debug data
    data
  end

  def self.get_args(param_hash, filter=false)
    data = '?'
    param_hash.each do |k,v|
      if !filter or filter.include? k
        data += "#{k}=#{v}&"
      end
    end
    data = data.gsub(/^(.*)&/, '\1 }')
    Puppet.debug data
    data
  end

end
