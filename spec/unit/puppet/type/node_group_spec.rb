require 'puppetlabs_spec_helper/module_spec_helper'

describe Puppet::Type.type(:node_group) do

  it "should allow agent-specified environment" do
    expect {
      Puppet::Type.type(:node_group).new(
        :name        => 'stubname',
        :environment => 'agent-specified',
      )
    }.to_not raise_error
  end

  it "should allow environment name with an underscore" do
    expect {
      Puppet::Type.type(:node_group).new(
        :name        => 'stubname',
        :environment => 'environment_name',
      )
    }.to_not raise_error
  end

  it "should allow environment name with a number" do
    expect {
      Puppet::Type.type(:node_group).new(
        :name        => 'stubname',
        :environment => 'environment1',
      )
    }.to_not raise_error
  end

  it "should allow environment name without an underscore" do
    expect {
      Puppet::Type.type(:node_group).new(
        :name        => 'stubname',
        :environment => 'name',
      )
    }.to_not raise_error
  end

  it "should allow environment name 'agent-specified'" do
    expect {
      Puppet::Type.type(:node_group).new(
        :name        => 'stubname',
        :environment => 'agent-specified',
      )
    }.to_not raise_error
  end

  it "should not allow environment name with a dash" do
    expect {
      Puppet::Type.type(:node_group).new(
        :name        => 'stubname',
        :environment => 'not-a-valid-name',
      )
    }.to raise_error(/Invalid environment name/)
  end

  it "should allow name with symbols, numbers, and whitespace" do
    expect {
      Puppet::Type.type(:node_group).new(
        :name => 'crAzy inSane n0dE grou$ N@mE',
      )
    }.to_not raise_error
  end

end
