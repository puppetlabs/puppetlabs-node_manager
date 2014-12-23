require 'net/http'
require 'uri'
require 'openssl'

Puppet::Type.type(:node_group).provide(:groups_endpoint) do
  confine :kernel => :Linux

  def self.instances
    node_groups = rest('GET', 'groups', false)
    new( 
      :name => 'foo',
      :blah => 'bar',
    )
  end

  def self.rest(method, endpoint, data)
    cert    = OpenSSL::X509::Certificate.new(File.read('/etc/puppetlabs/puppet/ssl/certs/pe-internal-dashboard.pem'))
    key     = OpenSSL::PKey::RSA.new(File.read('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-dashboard.pem'))
    ca_file = '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
    url     = "https://puppet:8140/classifier/v1/#{endpoint}"
    uri     = URI.parse(url)

    case method
    when 'GET'
      http             = Net::HTTP.new(uri.host, 443)
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.cert        = cert
      http.key         = key
      http.ca_file     = ca_file
      req              = Net::HTTP::Get.new(uri.path)
      resp             = http.request(req)
      return resp.body
    end
  end

end
