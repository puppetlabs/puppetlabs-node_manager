require_relative '../../puppet_x/node_manager/common'
require 'puppet/property/boolean'

Puppet::Type.newtype(:node_group) do
  desc 'The node_group type creates and manages node groups for the PE Node Manager'
  ensurable
  newparam(:name, namevar: true) do
    desc 'This is the common name for the node group'
  end
  newparam(:purge_behavior) do
    desc 'Whether or not to remove data or class parameters not specified'
    newvalues(:none, :data, :classes, :rule, :all)
    defaultto :all
  end
  newproperty(:id) do
    desc 'The ID of the group'
    validate do |_value|
      raise('ID is read-only')
    end
  end
  newproperty(:override_environment, boolean: true) do
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
      raise('Variables must be supplied as a hash') unless value.is_a?(Hash)
    end
  end
  newproperty(:rule, array_matching: :all) do
    desc 'Match conditions for this group'
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def should
      case @resource[:purge_behavior]
      # only do something special when we are asked to merge, otherwise, fall back to the default
      when :none
        # rule grammar
        #    condition : [ {bool} {condition}+ ] | [ "not" {condition} ] | {operation}
        #    bool : "and" | "or"
        #    operation : [ {operator} {fact-path} {value} ]
        #    operator : "=" | "~" | ">" | ">=" | "<" | "<=" | "<:"
        #    fact-path : {field-name} | [ {path-type} {field-name} {path-component}+ ]
        #    path-type : "trusted" | "fact"
        #    path-component : field-name | number
        #    field-name : string
        #    value : string

        a = @resource.property(:rule).retrieve || {}
        b = shouldorig

        # extract all pinned nodes if any
        # pinned nodes are in the form ['=', 'name', <hostname>]
        apinned = []
        a_without_pinned = a
        if a[0] == 'or'
          apinned = a.select { |item| (item[0] == '=') && (item[1] == 'name') }
          a_without_pinned = a.select { |item| (item[0] != '=') || (item[1] != 'name') }
        end
        bpinned = []
        b_without_pinned = b
        merged = []

        (return b.uniq.select { |item| (item != ['or'] && item != ['and']) } if a == [''])
        (return a.uniq.select { |item| (item != ['or'] && item != ['and']) } if b == [''])

        if b[0] == 'or'
          bpinned = b.select { |item| (item[0] == '=') && (item[1] == 'name') }
          b_without_pinned = b.select { |item| (item[0] != '=') || (item[1] != 'name') }
        end

        merged = if ((a[0] == 'and') || (a[0] == 'or')) && a[0] == b[0]
                   # if a and b start with the same 'and' or 'or' clause, we can just combine them
                   if a[0] == 'or'
                     (['or'] + a_without_pinned.drop(1) + b_without_pinned.drop(1) + apinned + bpinned).uniq
                   elsif apinned.length.positive? || bpinned.length.positive?
                     # must both be 'and' clauses
                     (['or'] + [a_without_pinned + b_without_pinned.drop(1)] + apinned + bpinned).uniq
                   # we have pinned nodes
                   else
                     # no pinned nodes and one top level 'and' clause, just combine them.
                     a_without_pinned + b_without_pinned.drop(1)
                   end
                 elsif a_without_pinned[0] == 'and' && b_without_pinned[0] == 'or'
                   # first clause of a and b aren't equal
                   # a first clause is one of and/or/not/operator
                   # b first clause is one of and/or/not/operator
                   # if a starts with `and` and b starts with `or`, create a top level `or` clause, nest a under it and append the rest of b
                   if a_without_pinned.length == 2
                     (['or'] + a_without_pinned[1] + b_without_pinned.drop(1) + apinned + bpinned)
                   else
                     (['or'] + [a_without_pinned] + b_without_pinned.drop(1) + apinned + bpinned)
                   end
                 # special case of a only having one subclause
                 elsif a_without_pinned[0] == 'or'
                   (a_without_pinned + [b_without_pinned] + apinned + bpinned).uniq
                 elsif b_without_pinned[0] == 'or'
                   # if b starts with 'or', we want to be sure to drop that.
                   (['or'] + [a_without_pinned] + b_without_pinned.drop(1) + apinned + bpinned)
                 else
                   (['or'] + [a_without_pinned] + [b_without_pinned] + apinned + bpinned)
                 end
        # ensure rules are unique at the top level and remove any empty rule sets
        merged.uniq.select { |item| (item != ['or'] && item != ['and']) }
      else
        super
      end
    end

    def insync?(is)
      is == should
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
  newproperty(:environment) do
    desc 'Environment for this group'
    defaultto :production
    validate do |value|
      raise("Invalid environment name: #{value}") unless value =~ (%r{\A[a-zA-Z0-9_]+\Z}) || (value == 'agent-specified')
    end
  end
  newproperty(:classes) do
    desc 'Classes applied to this group'
    defaultto {}
    validate do |value|
      raise('Classes must be supplied as a hash') unless value.is_a?(Hash)
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
        merged = a.merge(b) { |_k, x, y| x.merge(y) }
        PuppetX::Node_manager::Common.sort_hash(merged)
      end
    end
  end
  newproperty(:data) do
    desc 'Data applied to this group'
    # defaultto {}
    validate do |value|
      raise('Data must be supplied as a hash') unless value.is_a?(Hash)
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
        merged = a.merge(b) { |_k, x, y| x.merge(y) }
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
