require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe Puppet::Type.type(:node_group) do
  it 'allows agent-specified environment' do
    expect {
      Puppet::Type.type(:node_group).new(
        name: 'stubname',
        environment: 'agent-specified',
      )
    }.not_to raise_error
  end

  it 'allows environment name with an underscore' do
    expect {
      Puppet::Type.type(:node_group).new(
        name: 'stubname',
        environment: 'environment_name',
      )
    }.not_to raise_error
  end

  it 'allows environment name with a number' do
    expect {
      Puppet::Type.type(:node_group).new(
        name: 'stubname',
        environment: 'environment1',
      )
    }.not_to raise_error
  end

  it 'allows environment name without an underscore' do
    expect {
      Puppet::Type.type(:node_group).new(
        name: 'stubname',
        environment: 'name',
      )
    }.not_to raise_error
  end

  it "allows environment name 'agent-specified'" do
    expect {
      Puppet::Type.type(:node_group).new(
        name: 'stubname',
        environment: 'agent-specified',
      )
    }.not_to raise_error
  end

  it 'does not allow environment name with a dash' do
    expect {
      Puppet::Type.type(:node_group).new(
        name: 'stubname',
        environment: 'not-a-valid-name',
      )
    }.to raise_error(%r{Invalid environment name})
  end

  it 'allows name with symbols, numbers, and whitespace' do
    expect {
      Puppet::Type.type(:node_group).new(
        name: 'crAzy inSane n0dE grou$ N@mE',
      )
    }.not_to raise_error
  end

  it 'accepts a description parameter' do
    expect {
      Puppet::Type.type(:node_group).new(
        name: 'stubname',
        description: 'Sample message',
      )
    }.not_to raise_error
  end

  describe 'purge_behavior' do
    let(:and_rule) do
      ['and',
       ['~', ['fact', 'fact1'], 'value1'],
       ['~', ['fact', 'fact2'], 'value2']]
    end
    let(:or_rule) do
      ['or',
       ['~', ['fact', 'fact1'], 'value1'],
       ['~', ['fact', 'fact2'], 'value2']]
    end

    describe 'group_with_rule' do
      let(:group_with_rule) do
        {
          name: 'test_group',
          environment: 'test_env',
          classes: {
            'classes::class1' => { 'param1' => 'resource',
                                 'param2' => 'resource',
                                 'param3' => 'existing' },
            'classes::class3' => { 'param1' => 'existing',
                                  'param2' => 'existing' }
          },
          rule:
           ['or',
            ['~', ['fact', 'fact1'], 'value1'],
            ['~', ['fact', 'fact2'], 'value2']]
        }
      end
      let(:group_with_merged_and_rule) do
        ['or',
         ['and',
          ['~', ['fact', 'fact1'], 'value1'],
          ['~', ['fact', 'fact2'], 'value2']],
         ['~', ['fact', 'fact1'], 'value1'],
         ['~', ['fact', 'fact2'], 'value2']]
      end

      it 'replaces by default' do
        rsrc = described_class.new(group_with_rule)
        # this is simulated data from the classifier service
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq group_with_rule[:rule]
      end

      it 'merges when purge behaviour set to :none' do
        rsrc = described_class.new(group_with_rule.merge(purge_behavior: 'none'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq group_with_merged_and_rule
      end

      it 'replaces rule when purge behaviour set to :all' do
        rsrc = described_class.new(group_with_rule.merge(purge_behavior: 'all'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq group_with_rule[:rule]
      end

      it 'updates rule when purge behaviour set to :rule' do
        rsrc = described_class.new(group_with_rule.merge(purge_behavior: 'rule'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq group_with_rule[:rule]
      end
    end

    describe 'group with pinned nodes' do
      let(:group_with_pinned_nodes) do
        {
          name: 'test_group',
          environment: 'test_env',
          classes: {
            'classes::class1' => { 'param1' => 'resource',
                                 'param2' => 'resource',
                                 'param3' => 'existing' },
            'classes::class3' => { 'param1' => 'existing',
                                  'param2' => 'existing' }
          },
          rule:
           ['or',
            ['=', 'name', 'value1'],
            ['=', 'name', 'value2'],
            ['=', 'name', 'value2']]
        }
      end

      # when merging the pinned nodes and the and rule, the top level "or" clause should be maintained, and the pinned nodes added
      # to the end
      # also the merging optimizes the pinned nodes to remove redundants.
      let(:merged_pinned_nodes_and_rule) do
        ['or',
         ['and',
          ['~', ['fact', 'fact1'], 'value1'],
          ['~', ['fact', 'fact2'], 'value2']],
         ['=', 'name', 'value1'],
         ['=', 'name', 'value2']]
      end

      let(:merged_pinned_nodes_or_rule) do
        ['or',
         ['~', ['fact', 'fact1'], 'value1'],
         ['~', ['fact', 'fact2'], 'value2'],
         ['=', 'name', 'value1'],
         ['=', 'name', 'value2']]
      end

      it 'matches rule exactly by default' do
        rsrc = described_class.new(group_with_pinned_nodes)
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq group_with_pinned_nodes[:rule]
      end

      it 'merges and rule correctly when purge behaviour set to :none' do
        rsrc = described_class.new(group_with_pinned_nodes.merge(purge_behavior: 'none'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq merged_pinned_nodes_and_rule
      end

      it 'merges or rule correctly when purge behaviour set to :none' do
        rsrc = described_class.new(group_with_pinned_nodes.merge(purge_behavior: 'none'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(or_rule)
        expect(rsrc.property(:rule).should).to eq merged_pinned_nodes_or_rule
      end

      it 'merges pinned node correctly when purge behaviour set to :none' do
        rsrc = described_class.new(group_with_pinned_nodes.merge(purge_behavior: 'none'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(['=', 'name', 'value2'])
        # redundant node pinning is removed
        expect(rsrc.property(:rule).should).to eq ['or', ['=', 'name', 'value2'], ['=', 'name', 'value1']]
      end

      it 'replaces rule when purge behaviour set to :all' do
        rsrc = described_class.new(group_with_pinned_nodes.merge(purge_behavior: 'all'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq group_with_pinned_nodes[:rule]
      end

      it 'replaces rule when purge behaviour set to :rule' do
        rsrc = described_class.new(group_with_pinned_nodes.merge(purge_behavior: 'rule'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq group_with_pinned_nodes[:rule]
      end
    end

    describe 'group with top-level and clause' do
      let(:group_with_and_clause) do
        {
          name: 'test_group',
          environment: 'test_env',
          classes: {
            'classes::class1' => { 'param1' => 'resource',
                                 'param2' => 'resource',
                                 'param3' => 'existing' },
            'classes::class3' => { 'param1' => 'existing',
                                  'param2' => 'existing' }
          },
          rule:
           ['and', ['~', ['fact', 'pe_server_version'], '.+']]
        }
      end

      let(:rule_combined_and_clauses) do
        ['and',
         ['~', ['fact', 'fact1'], 'value1'],
         ['~', ['fact', 'fact2'], 'value2'],
         ['~', ['fact', 'pe_server_version'], '.+']]
      end

      let(:rule_combined_or_clauses) do
        ['or',
         ['~', ['fact', 'fact1'], 'value1'],
         ['~', ['fact', 'fact2'], 'value2'],
         ['and', ['~', ['fact', 'pe_server_version'], '.+']]]
      end

      it 'replaces rule exactly by default' do
        rsrc = described_class.new(group_with_and_clause)
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq group_with_and_clause[:rule]
      end

      it 'merges and rule correctly when purge behaviour set to :none' do
        rsrc = described_class.new(group_with_and_clause.merge(purge_behavior: 'none'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq rule_combined_and_clauses
      end

      it 'merges or rule correctly when purge behaviour set to :none' do
        rsrc = described_class.new(group_with_and_clause.merge(purge_behavior: 'none'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(or_rule)
        expect(rsrc.property(:rule).should).to eq rule_combined_or_clauses
      end

      it 'merges pinned node correctly when purge behaviour set to :none' do
        rsrc = described_class.new(group_with_and_clause.merge(purge_behavior: 'none'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(['=', 'name', 'value2'])
        # redundant node pinning is removed
        expect(rsrc.property(:rule).should).to eq ['or', ['=', 'name', 'value2'], ['and', ['~', ['fact', 'pe_server_version'], '.+']]]
      end

      it 'replaces rule when purge behaviour set to :all' do
        rsrc = described_class.new(group_with_and_clause.merge(purge_behavior: 'all'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq group_with_and_clause[:rule]
      end

      it 'replaces rule when purge behaviour set to :rule' do
        rsrc = described_class.new(group_with_and_clause.merge(purge_behavior: 'rule'))
        allow(rsrc.property(:rule)).to receive(:retrieve).and_return(and_rule)
        expect(rsrc.property(:rule).should).to eq group_with_and_clause[:rule]
      end
    end

    describe 'resource hash' do
      let(:resource_hash) do
        {
          name: 'test_group',
          environment: 'test_env',
          data: {
            'data::class1' => { 'param1' => 'resource',
                                'param2' => 'resource' },
            'data::class2' => { 'param1' => 'resource',
                                'param2' => 'resource' },
          },
          classes: {
            'classes::class1' => { 'param1' => 'resource',
                                   'param2' => 'resource' },
          },
        }
      end

      let(:existing_data) do
        { 'data::class1' => { 'param1' => 'existing',
                              'param3' => 'existing' },
          'data::class3' => { 'param1' => 'existing',
                              'param2' => 'existing' } }
      end
      let(:merged_data) do
        { 'data::class1' => { 'param1' => 'resource',
                              'param2' => 'resource',
                              'param3' => 'existing' },
          'data::class2' => { 'param1' => 'resource',
                              'param2' => 'resource' },
          'data::class3' => { 'param1' => 'existing',
                              'param2' => 'existing' } }
      end

      let(:existing_classes) do
        { 'classes::class1' => { 'param1' => 'existing',
                                 'param3' => 'existing' },
          'classes::class3' => { 'param1' => 'existing',
                                 'param2' => 'existing' } }
      end
      let(:merged_classes) do
        { 'classes::class1' => { 'param1' => 'resource',
                                 'param2' => 'resource',
                                 'param3' => 'existing' },
          'classes::class3' => { 'param1' => 'existing',
                                 'param2' => 'existing' } }
      end

      it 'matches classes and data exactly by default' do
        rsrc = described_class.new(resource_hash)
        allow(rsrc.property(:data)).to receive(:retrieve).and_return(existing_data)
        allow(rsrc.property(:classes)).to receive(:retrieve).and_return(existing_classes)
        expect(rsrc.property(:data).should).to eq resource_hash[:data]
        expect(rsrc.property(:classes).should).to eq resource_hash[:classes]
      end

      it 'merges in classes and data when set to :none' do
        rsrc = described_class.new(resource_hash.merge(purge_behavior: 'none'))
        allow(rsrc.property(:data)).to receive(:retrieve).and_return(existing_data)
        allow(rsrc.property(:classes)).to receive(:retrieve).and_return(existing_classes)
        expect(rsrc.property(:data).should).to eq(merged_data)
        expect(rsrc.property(:classes).should).to eq(merged_classes)
      end

      it 'merges in classes and match data exactly when set to :data' do
        rsrc = described_class.new(resource_hash.merge(purge_behavior: 'data'))
        allow(rsrc.property(:data)).to receive(:retrieve).and_return(existing_data)
        allow(rsrc.property(:classes)).to receive(:retrieve).and_return(existing_classes)
        expect(rsrc.property(:data).should).to eq(resource_hash[:data])
        expect(rsrc.property(:classes).should).to eq(merged_classes)
      end

      it 'merges in data and match classes exactly when set to :classes' do
        rsrc = described_class.new(resource_hash.merge(purge_behavior: 'classes'))
        allow(rsrc.property(:data)).to receive(:retrieve).and_return(existing_data)
        allow(rsrc.property(:classes)).to receive(:retrieve).and_return(existing_classes)
        expect(rsrc.property(:data).should).to eq(merged_data)
        expect(rsrc.property(:classes).should).to eq(resource_hash[:classes])
      end
    end
  end

  describe '.insync? for data, classes' do
    let(:hash) do
      {
        'class1' => { 'param1' => 'value1',
                      'param2' => 'value2' },
        'class2' => { 'param1' => 'value1',
                      'param2' => 'value2' },
        'class3' => { 'param1' => 'value1',
                      'param2' => 'value2' },
      }
    end
    let(:resource) do
      described_class.new({
                            name: 'test_group',
        environment: 'test_env',
        classes: hash,
        data: hash,
                          })
    end

    before(:each) do
      allow(resource.property(:data)).to receive(:should).and_return(hash)
      allow(resource.property(:classes)).to receive(:should).and_return(hash)
    end

    it 'is insync when `is` and `should` are identical' do
      expect(resource.property(:data).insync?(hash)).to eq(true)
      expect(resource.property(:classes).insync?(hash)).to eq(true)
    end

    it 'is insync when `is` and `should` are identical but have different ordering' do
      reverse_hash = hash.to_a.map { |i| [i[0], i[1].to_a.reverse.to_h] }.reverse.to_h
      expect(resource.property(:data).insync?(reverse_hash)).to eq(true)
      expect(resource.property(:classes).insync?(reverse_hash)).to eq(true)
    end

    it 'is not insync when `is` is only a subset of `should`' do
      subset = hash.select { |k| k != 'class2' }
      expect(resource.property(:data).insync?(subset)).to eq(false)
      expect(resource.property(:classes).insync?(subset)).to eq(false)
    end
  end
end
# rubocop:enable Metrics/BlockLength
