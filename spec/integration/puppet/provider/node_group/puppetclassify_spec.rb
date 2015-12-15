require 'puppetlabs_spec_helper/module_spec_helper'
require 'webmock/rspec'

describe Puppet::Type.type(:node_group).provider(:puppetclassify) do

  GROUPS_RESPONSE = <<-EOS
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
    }
  ]
  EOS

  CREATE_REQUEST = '{"environment_trumps":"false","parent":"00000000-0000-4000-8000-000000000000","rule":["or",["=","name","master.puppetlabs.vm"]],"environment":"stubenvironment","classes":{"puppet_enterprise::profile::amq::broker":{}},"variables":{"stubkey":"stubvalue","stubkey2":"stubvalue2"},"name":"stub_name"}'

  subject do
    Puppet::Type.type(:node_group).new(
      :name                 => 'stub_name',
      :override_environment => 'false',
      :parent               => 'All Nodes',
      :rule                 => ['or', ['=', 'name', 'master.puppetlabs.vm']],
      :environment          => 'stubenvironment',
      :classes              => {'puppet_enterprise::profile::amq::broker' => {}},
      :variables            => {
        :stubkey  => :stubvalue,
        :stubkey2 => :stubvalue2,
      },
    )
  end

  before do
      YAML.stubs(:load_file).with('/dev/null/classifier.yaml')
        .returns({'server' => 'stubserver', 'port' => '8080'})
  end

  describe "#instances" do
    it "returns each node group" do
      stub_request(:get, "https://stubserver:8080/classifier-api/v1/groups")
        .to_return(:status => 200, :body => GROUPS_RESPONSE)
      res = subject.provider.class.instances
      expect(res.count).to be(1)
      expect(res[0]).to be_a(Puppet::Provider)
    end
  end

  describe ".create" do
    it "creates the node group" do
      stub_request(:post, "https://stubserver:8080/classifier-api/v1/groups")
        .to_return(:status => 303, :headers => {:location => "/classifier-api/v1/groups/stubid"})
      subject.provider.create
      assert_requested(:post, "https://stubserver:8080/classifier-api/v1/groups", :body => CREATE_REQUEST) 
    end
  end

  describe ".destroy" do
    it "deletes the node group" do
      stub_request(:delete, "https://stubserver:8080/classifier-api/v1/groups/")
        .to_return(:status => 204)
      subject.provider.destroy
      assert_requested(:delete, "https://stubserver:8080/classifier-api/v1/groups/")
    end
  end

  describe ".flush" do
    it "updates the node group" do
      stub_request(:post, "https://stubserver:8080/classifier-api/v1/groups/")
        .to_return(:status => 200)
      subject.provider.flush
      assert_requested(:post, "https://stubserver:8080/classifier-api/v1/groups/")
    end
  end

end
