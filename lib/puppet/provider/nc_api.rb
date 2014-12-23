class Puppet::Provider::Nc_api < Puppet::Provider
require 'net/http'
require 'openssl'

  def self.rest(method, endpoint, data=false)
    cert    = OpenSSL::X509::Certificate.new(File.read('/etc/puppetlabs/puppet/ssl/certs/pe-internal-dashboard.pem'))
    key     = OpenSSL::PKey::RSA.new(File.read('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-dashboard.pem'))
    ca_file = '/etc/puppetlabs/puppet/ssl/certs/ca.pem'

    case method
    when 'GET'
      http             = Net::HTTP.new('puppet', 4433)
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.cert        = cert
      http.key         = key
      http.ca_file     = ca_file
      req              = Net::HTTP::Get.new("/classifier-api/v1/#{endpoint}")
      resp             = http.request(req)
      debug "Response code #{resp.code}"
      resp.body
    end
  end

end
