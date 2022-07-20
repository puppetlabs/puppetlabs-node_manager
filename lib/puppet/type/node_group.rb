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

    # check for fact rule in deep array
    def factcheck(rulecheck)
      rulecheck.each_with_index {|x, i|
        if x == "fact" and i == 0
          return true
        end
        if x.kind_of?(Array)
          if factcheck(x)
            return true
          end
        end
      }
      false
    end

    def should
      case @resource[:purge_behavior]
      when :rule, :all
        super
      else
        a = shouldorig
        b = @resource.property(:rule).retrieve || {}
        borig = b.map(&:clone)
        btmp = b.map(&:clone)
        # check if the node classifer has any rules defined before attempting merge.
        if b.length >= 2
          if b[0] == "or" and b[1][0] == "or" or b[1][0] == "and"
            # We are merging both rules and pinned nodes
            if a[0] == "or" and a[1][0] == "or" or a[1][0] == "and"
              # a has rules to merge
              rules = (btmp[1] + a[1].drop(1)).uniq
              btmp[1] = rules
              pinned = (a[2,a.length] + btmp[2,btmp.length]).uniq
              merged = (btmp + pinned).uniq
            elsif a[0] == "and" or a[0] == "or" and factcheck(a)
              # a only has rules to merge
              rules = (btmp[1] + a.drop(1)).uniq
              btmp[1] = rules
              merged = btmp
            else
              pinned = (a[1,a.length] + btmp[2,btmp.length]).uniq
              merged = (btmp + pinned).uniq
            end
          elsif a[0] == "or" and a[1][0] == "or" or a[1][0] == "and"
            # We are merging both rules and pinned nodes
            rules = a[1] # no rules to merge on B side
            pinned = (a[2,a.length] + b[1,b.length]).uniq
            merged = (a + pinned).uniq
          elsif b[0] == "and" or b[0] == "or" and factcheck(b)
            # b only has fact rules
            if a[0] == "or" and not factcheck(a)
              # a only has pinned nodes
              rules = btmp
              temp = ['or']
              temp[1] = btmp
              merged = (temp + a[1,a.length]).uniq
            else
              # a only has rules
              merged = (b + a.drop(1)).uniq
            end
          elsif b[0] == "or" and b[1][1] == "name"
            # b only has pinned nodes
            if a[0] == "or" and not factcheck(a)
              # a only has pinned nodes
              merged = (a + b.drop(1)).uniq
            else
              # a only has rules
              temp = ['or']
              temp[1] = a
              merged = (temp + btmp[1,btmp.length]).uniq
            end
          else
            # We are only doing rules OR pinned nodes
            puts "default rule - might fail - Pullout before PR to main project"
            merged = (a + b.drop(1)).uniq
          end
          if merged == borig
            # values are the same, returning orginal value"
            borig
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
