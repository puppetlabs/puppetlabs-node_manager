require 'spec_helper'

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

  it "should accept a description parameter" do
    expect {
      Puppet::Type.type(:node_group).new(
        :name        => 'stubname',
        :description => 'Sample message',
      )
    }.to_not raise_error
  end

  describe "purge_behavior" do
    let(:resource_hash) do
      {
        :name        => 'test_group',
        :environment => 'test_env',
        :data        => {
          'data::class1' => { 'param1' => 'resource',
                              'param2' => 'resource' },
          'data::class2' => { 'param1' => 'resource',
                              'param2' => 'resource' },
        },
        :classes     => {
          'classes::class1' => { 'param1' => 'resource',
                                 'param2' => 'resource' },
        },
      }
    end

    let(:existing_data) do
      {
        'data::class1' => { 'param1' => 'existing',
                            'param3' => 'existing' },
        'data::class3' => { 'param1' => 'existing',
                            'param2' => 'existing' },
      }
    end

    let(:existing_classes) do
      {
        'classes::class1' => { 'param1' => 'existing',
                               'param3' => 'existing' },
        'classes::class3' => { 'param1' => 'existing',
                               'param2' => 'existing' },
      }
    end

    it "should match classes and data exactly by default" do
      resource = described_class.new(resource_hash)

      allow(resource.property(:data)).to receive(:retrieve).and_return(existing_data)
      allow(resource.property(:classes)).to receive(:retrieve).and_return(existing_classes)

      data_should = resource.property(:data).should
      classes_should = resource.property(:classes).should

      expect(data_should).to eq resource_hash[:data]
      expect(classes_should).to eq resource_hash[:classes]
    end

    it "should merge in classes and data when set to :none" do
      resource = described_class.new(resource_hash.merge(:purge_behavior => 'none'))

      allow(resource.property(:data)).to receive(:retrieve).and_return(existing_data)
      allow(resource.property(:classes)).to receive(:retrieve).and_return(existing_classes)

      data_should = resource.property(:data).should
      classes_should = resource.property(:classes).should

      expect(data_should).to eq ({ "data::class1" => { "param1" => "resource",
                                                       "param2" => "resource",
                                                       "param3" => "existing"},
                                   "data::class2" => { "param1" => "resource",
                                                       "param2" => "resource"},
                                   "data::class3" => { "param1" => "existing",
                                                       "param2" => "existing"}})

      expect(classes_should).to eq ({ "classes::class1" => { "param1" => "resource",
                                                             "param2" => "resource",
                                                             "param3" => "existing"},
                                      "classes::class3" => { "param1" => "existing",
                                                             "param2" => "existing"}})
    end

    it "should merge in classes and match data exactly when set to :data" do
      resource = described_class.new(resource_hash.merge(:purge_behavior => 'data'))

      allow(resource.property(:data)).to receive(:retrieve).and_return(existing_data)
      allow(resource.property(:classes)).to receive(:retrieve).and_return(existing_classes)

      data_should = resource.property(:data).should
      classes_should = resource.property(:classes).should

      expect(data_should).to eq (resource_hash[:data])

      expect(classes_should).to eq ({ "classes::class1" => { "param1" => "resource",
                                                             "param2" => "resource",
                                                             "param3" => "existing"},
                                      "classes::class3" => { "param1" => "existing",
                                                             "param2" => "existing"}})
    end

    it "should merge in data and match classes exactly when set to :classes" do
      resource = described_class.new(resource_hash.merge(:purge_behavior => 'classes'))

      allow(resource.property(:data)).to receive(:retrieve).and_return(existing_data)
      allow(resource.property(:classes)).to receive(:retrieve).and_return(existing_classes)

      data_should = resource.property(:data).should
      classes_should = resource.property(:classes).should

      expect(data_should).to eq ({ "data::class1" => { "param1" => "resource",
                                                       "param2" => "resource",
                                                       "param3" => "existing"},
                                   "data::class2" => { "param1" => "resource",
                                                       "param2" => "resource"},
                                   "data::class3" => { "param1" => "existing",
                                                       "param2" => "existing"}})

      expect(classes_should).to eq (resource_hash[:classes])
    end
  end

end
