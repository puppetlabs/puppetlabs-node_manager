require 'puppet_x/node_manager/common'
require 'puppet/property/boolean'

Puppet::Type.newtype(:node_group) do
  desc 'The node_group type creates and manages node groups for the PE Node Manager'
  ensurable
  newparam(:name, :namevar => true) do
    desc 'This is the common name for the node group'
  end
  newparam(:purge_behavior) do
    desc 'Whether or not to remove data or class parameters not specified'
    newvalues(:none, :data, :classes, :rule, :all)
    defaultto :all
  end
  newproperty(:id) do
    desc 'The ID of the group'
    validate do |value|
      fail("ID is read-only")
    end
  end
  newproperty(:override_environment, :boolean => true) do
    desc 'Override parent environments'
    munge do |value|
      Puppet::Coercion.boolean(value).to_s.to_sym
    end
  end
  newproperty(:parent) do
    desc 'The ID of the parent group'
  end
  newproperty(:variables) do
    desc 'Variables set this group\'s scope'
    validate do |value|
      fail("Variables must be supplied as a hash") unless value.is_a?(Hash)
    end
  end
  newproperty(:rule, :array_matching => :all) do
    desc 'Match conditions for this group'
    defaultto []
    def should
      case @resource[:purge_behavior]
      when :rule, :all
        super
      else
        a = shouldorig
        b = @resource.property(:rule).retrieve || {}
        # check if the node classifer has any rules defined before attempting merge.
        if b.length >= 2
          if b[0] == "or" and b[1][0] == "or" or b[1][0] == "and"
            # We are merging both rules and pinned nodes
            rules = (b[1] + a[1].drop(1)).uniq
            pinned = (a[2,a.length] + b[2,b.length]).uniq
            b[1] = rules
            merged = (b + pinned).uniq
          elsif a[0] == "or" and a[1][0] == "or" or a[1][0] == "and"
            # We are merging both rules and pinned nodes
            rules = a[1] # no rules to merge on B side
            pinned = (a[2,a.length] + b[2,b.length]).uniq
            merged = (a + pinned).uniq
          else
            # We are only doing rules OR pinned nodes
            merged = (a + b.drop(1)).uniq
          end
          if merged == b
            # values are the same, returning orginal value"
            b
          else
            merged
          end
        else
          a
        end
      end
    end
    def insync?(is)
      is == should
    end
  end
  newproperty(:environment) do
    desc 'Environment for this group'
    defaultto :production
    validate do |value|
      fail("Invalid environment name") unless value =~ /\A[a-z0-9_]+\Z/ or value == 'agent-specified'
    end
  end
  newproperty(:classes) do
    desc 'Classes applied to this group'
    defaultto {}
    validate do |value|
      fail("Classes must be supplied as a hash") unless value.is_a?(Hash)
    end
    # Need to deep sort hashes so they be evaluated equally
    munge do |value|
      PuppetX::Node_manager::Common.sort_hash(value)
    end
    def should
      case @resource[:purge_behavior]
      when :classes, :all
        super
      else
        a = @resource.property(:classes).retrieve || {}
        b = shouldorig.first
        merged = a.merge(b) { |k, x, y| x.merge(y) }
        PuppetX::Node_manager::Common.sort_hash(merged)
      end
    end
  end
  newproperty(:data) do
    desc 'Data applied to this group'
    #defaultto {}
    validate do |value|
      fail("Data must be supplied as a hash") unless value.is_a?(Hash)
    end
    # Need to deep sort hashes so they be evaluated equally
    munge do |value|
      PuppetX::Node_manager::Common.sort_hash(value)
    end
    def should
      case @resource[:purge_behavior]
      when :data, :all
        super
      else
        a = @resource.property(:data).retrieve || {}
        b = shouldorig.first
        merged = a.merge(b) { |k, x, y| x.merge(y) }
        PuppetX::Node_manager::Common.sort_hash(merged)
      end
    end
  end
  newproperty(:description) do
    desc 'Description of this group'
  end

  autorequire(:node_group) do
    self[:parent] if @parameters.include? :parent
  end

end
