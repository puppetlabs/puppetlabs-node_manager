require 'net/http'
require 'openssl'
require 'json'

Puppet::Type.type(:node_group).provide(:node_group) do

  def self.instances
    ngs = JSON.parse(rest('GET', 'groups'))
    ngs.collect do |group|
      new(
        :name   => group['name'],
        :ensure => :present,
        :id     => group['id']
      )
    end
  end

  def self.prefetch(resources)
    ngs = instances
    resources.keys.each do |group|
      if provider = ngs.find{ |g| g.name == group }
        resources[group].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  mk_resource_methods

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
      resp.body
    end
  end

end
