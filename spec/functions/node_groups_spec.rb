require 'spec_helper'
require 'puppet/util/nc_https'
require 'webmock/rspec'

describe 'node_groups' do
  describe 'input validation' do
    it { is_expected.to run.with_params('', '', [], '', 'extra').and_raise_error(ArgumentError, /Function accepts a single String/i) }
    it { is_expected.to run.with_params([]).and_raise_error(ArgumentError, /Function accepts a single String/i) }
  end

  groups_response = <<-EOS
  [
    {
        "classes": {},
        "environment": "production",
        "environment_trumps": false,
        "id": "00000000-0000-4000-8000-000000000000",
        "name": "All Nodes",
        "parent": "00000000-0000-4000-8000-000000000000",
        "rule": [
            "and",
            [
                "~",
                "name",
                ".*"
            ]
        ],
        "variables": {}
    },
    {
        "classes": {},
        "environment": "production",
        "environment_trumps": false,
        "id": "7233f964-951e-4a7f-88ea-72676ed3104d",
        "name": "Production environment",
        "parent": "00000000-0000-4000-8000-000000000000",
        "rule": [
            "and",
            [
                "~",
                "name",
                ".*"
            ]
         ],
        "variables": {}
    }
  ]
  EOS

  hashified = {
    'All Nodes'            => {
      'classes'            => {},
      'environment'        => 'production',
      'environment_trumps' => false,
      'id'                 => '00000000-0000-4000-8000-000000000000',
      'name'               => 'All Nodes',
      'parent'             => '00000000-0000-4000-8000-000000000000',
      'rule'               => ['and', ['~', 'name', '.*']],
      'variables'          => {},
    },
    'Production environment' => {
      'classes'              => {},
      'environment'          => 'production',
      'environment_trumps'   => false,
      'id'                   => '7233f964-951e-4a7f-88ea-72676ed3104d',
      'name'                 => 'Production environment',
      'parent'               => '00000000-0000-4000-8000-000000000000',
      'rule'                 => ['and', ['~', 'name', '.*']],
      'variables'            => {},
    }
  }

  before do
    nc = double("NC", :get_groups => JSON.parse(groups_response))
    allow(Puppet::Util::Nc_https).to receive(:new).and_return(nc)
  end

  describe 'without an argument' do
    it { should run.with_params().and_return(hashified) }
  end

  describe 'with 1 String argument' do
    it { should run.with_params('All Nodes').and_return({ 'All Nodes' => hashified['All Nodes']}) }
  end
end
