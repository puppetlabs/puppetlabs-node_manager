require 'puppetlabs_spec_helper/module_spec_helper'
require 'webmock/rspec'

describe Puppet::Type.type(:puppet_environment).provider(:puppet_environment) do

  ENVIRONMENT_RESPONSE = <<-EOS
  [
  {"name": "stub name 1"},
  {"name": "stub name 2"}
  ]
  EOS

  subject do
    Puppet::Type.type(:puppet_environment).new(
      :name => 'stub_environment_name',
    )
  end

  before do
    File.stubs(:read)
    YAML.stubs(:load_file).with('/dev/null/classifier.yaml')
      .returns({'server' => 'stubserver', 'port' => '8080'})

    OpenSSL::X509::Certificate.stubs(:new).returns('stub cert')
    OpenSSL::PKey::RSA.stubs(:new).returns('stub key')
  end

  describe "#instances" do
    it "returns each environment" do
      stub_request(:get, "https://stubserver:8080/classifier-api/v1/environments").
        to_return(:status => 200, :body => ENVIRONMENT_RESPONSE)

      res = subject.provider.class.instances
      expect(res.count).to be(2)
    end
  end

  describe ".create" do
    it "creates the environment" do
      stub_request(:put, "https://stubserver:8080/classifier-api/v1/environments/stub_environment_name").
        to_return(:status => 201)

      subject.provider.create

      assert_requested(:put, "https://stubserver:8080/classifier-api/v1/environments/stub_environment_name")
    end
  end

  describe ".destroy" do
    it "deletes the environment" do
      stub_request(:delete, "https://stubserver:8080/classifier-api/v1/environments/").
        to_return(:status => 201)

      subject.provider.destroy

      assert_requested(:delete, "https://stubserver:8080/classifier-api/v1/environments/")
    end
  end

end
