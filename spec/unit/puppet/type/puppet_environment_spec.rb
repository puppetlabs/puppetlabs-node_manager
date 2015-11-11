require 'puppetlabs_spec_helper/module_spec_helper'

describe Puppet::Type.type(:puppet_environment) do

  it "should allow environment name with an underscore" do
    expect {
      Puppet::Type.type(:puppet_environment).new(
        :name => 'environment_name',
      )
    }.to_not raise_error
  end

  it "should allow environment name with a number" do
    expect {
      Puppet::Type.type(:puppet_environment).new(
        :name => 'environment1',
      )
    }.to_not raise_error
  end

  it "should allow environment name without an underscore" do
    expect {
      Puppet::Type.type(:puppet_environment).new(
        :name => 'name',
      )
    }.to_not raise_error
  end

  it "should allow 'agent-specified' environment" do
    expect {
      Puppet::Type.type(:puppet_environment).new(
        :name => 'agent-specified',
      )
    }.to_not raise_error
  end

  it "should not allow environment name with a dash" do
    expect {
      Puppet::Type.type(:puppet_environment).new(
        :name => 'not-a-valid-name',
      )
    }.to raise_error(/not-a-valid-name is not a valid environment name/)
  end


end
