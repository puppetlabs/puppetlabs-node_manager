require 'spec_helper'

type_class = Puppet::Type.type(:node_group)
describe type_class do

  before :each do
    Puppet.settings['localcacert'] = '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
    Puppet.settings['hostcert']    = '/etc/puppetlabs/puppet/ssl/certs/master.puppetlabs.vm.pem'
    Puppet.settings['hostprivkey'] = '/etc/puppetlabs/puppet/ssl/private_keys/master.puppetlabs.vm.pem'
  end

  it 'should not accept an id attribute' do
    expect {
      type_class.new({:name => 'asterix', :id => '1'})
    }.to raise_error /ID is read-only/
  end

end
