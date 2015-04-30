require 'puppet'
require 'puppet/type/node_group'
describe Puppet::Type.type(:node_group) do
  let(:resource) {
    Puppet::Type.type(:node_group).new(
      :ensure               => 'present',
      :classes              => {'puppet_enterprise::profile::mcollective::agent' => {}},
      :environment          => 'production',
      :override_environment => 'false',
      :parent               => 'PE Infrastructure',
      :rule                 => ['and', ['~', ['fact', 'pe_version'], '.+']]
    )
  }

  it 'should not accept an id attribute' do
    expect {
      type_class[:id] = '1'
    }.to raise_error /ID is read-only/
  end

end
