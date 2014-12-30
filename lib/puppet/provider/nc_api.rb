class Puppet::Provider::Nc_api < Puppet::Provider
require 'net/http'
require 'openssl'
require 'pry'

  def self.rest(method, endpoint, data=false)

    rest_endpoint    = "/classifier-api/v1/#{endpoint}"
    http             = Net::HTTP.new('puppet', 4433)
    http.use_ssl     = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.cert        = OpenSSL::X509::Certificate.new(File.read('/etc/puppetlabs/puppet/ssl/certs/pe-internal-dashboard.pem'))
    http.key         = OpenSSL::PKey::RSA.new(File.read('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-dashboard.pem'))
    http.ca_file     = '/etc/puppetlabs/puppet/ssl/certs/ca.pem'

    case method
    when 'GET'
      req      = Net::HTTP::Get.new(rest_endpoint)
    when 'POST'
      req      = Net::HTTP::Post.new(rest_endpoint)
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
    when '303'
      info "New group at #{resp['Location']}"
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
end
