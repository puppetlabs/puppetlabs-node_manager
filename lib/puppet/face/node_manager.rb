require 'puppet'
require 'puppet/face'
require_relative '../util/nc_https'
require_relative '../../puppet_x/node_manager/common'

Puppet::Face.define(:node_manager, '0.1.0') do
  summary 'Interact with node classifier API'
  copyright 'WhatsARanjit', 2017
  license 'Apache-2.0'

  classifier = Puppet::Util::Nc_https.new
  output     = []

  action :groups do
    summary 'List group information'
    arguments '[group_name]'

    option '--export' do
      summary 'Provide formatted JSON for import'
      default_to { false }
    end

    option '--import JSONFILE' do
      summary 'Import formatted JSON of groups'
      default_to { false }
    end

    when_invoked do |*args|
      options = args.last

      if options[:import]
        raise('Choose import or export') if options[:export]

        'Success' if classifier.import_hierarchy(read_import(options[:import]))
      else
        groups = classifier.get_groups

        if args.length == 2
          output << groups.select { |g| g['name'] == args.first }
        elsif args.length == 1
          output << groups
        else
          raise("wrong number of arguments (#{args.length - 1} for 1)")
        end
        if options[:export]
          output.flatten.to_json
        else
          PuppetX::Node_manager::Common.hashify_group_array(output.flatten)
        end
      end
    end

    when_rendering :console do |output|
      case output
      when Hash
        if output.length == 0
          raise('No groups found')
        elsif output.length == 1
          JSON.pretty_generate output.values[0]
        else
          output.keys
        end
      else
        output
      end
    end
  end

  action :classes do
    summary 'List class information'
    arguments '[class]'

    option '--update' do
      summary 'Trigger classifier to update class list'
      default_to { false }
    end

    when_invoked do |*args|
      options    = args.last
      klass      = args.first.is_a?(String) ? args.first : false
      env        = options[:environment] ? options[:environment] : 'production'
      queryenv   = options[:environment] ? options[:environment] : nil

      if options[:update]
        'Success' if classifier.update_classes(queryenv)
      else
        output << classifier.get_classes(env, klass)
        PuppetX::Node_manager::Common.hashify_group_array(output.flatten)
      end
    end

    when_rendering :console do |output|
      case output
      when Hash
        if output.length <= 1
          JSON.pretty_generate output.values[0]
        else
          output.keys
        end
      else
        output
      end
    end
  end

  action :classified do
    summary 'List classification information'
    arguments 'nodename'

    option '--explain' do
      summary 'Provide explanation'
      default_to { false }
    end

    option '--facts FACTSFILE' do
      summary 'Provide facts YAML or JSON'
      default_to { false }
    end

    option '--trusted TRUSTEDFILE' do
      summary 'Provide trusted facts YAML or JSON'
      default_to { false }
    end

    when_invoked do |nodename, options|
      output << classifier.get_classified(
        nodename,
        options[:explain],
        check_facts(options[:facts], options),
        check_facts(options[:trusted], options),
      )
      output.flatten
    end

    when_rendering :console do |output, _nodename, options|
      if options[:explain] == true
        JSON.pretty_generate output.first['match_explanations']
      else
        JSON.pretty_generate output.first['classes']
      end
    end
  end

  action :pin do
    summary 'Pin a node to a group'
    arguments 'nodename'

    option '--node_group GROUP' do
      summary 'Node group to pin to'
      default_to { '00000000-0000-4000-8000-000000000000' }
    end

    when_invoked do |*args|
      nodename = args.first
      options  = args.last

      if options[:node_group]
        'Success' if classifier.pin_node(nodename, options[:node_group])
      end
    end

    when_rendering :console do |output|
      case output
      when Hash
        if output.length <= 1
          JSON.pretty_generate output.values[0]
        else
          output.keys
        end
      else
        output
      end
    end
  end

  action :unpin do
    summary 'Unpin a node from a group'
    arguments 'nodename'

    option '--all' do
      summary 'Unpin a node from all groups'
      default_to { false }
    end

    option '--node_group GROUP' do
      summary 'Node group to unpin from'
      default_to { '00000000-0000-4000-8000-000000000000' }
    end

    when_invoked do |nodename, options|
      if options[:all]
        output << classifier.unpin_from_all(nodename)
        if output.flatten.first['nodes'].empty?
          'Found nothing to unpin.'
        else
          PuppetX::Node_manager::Common.hashify_group_array(output.flatten.first['nodes'])
        end
      elsif classifier.unpin_node(nodename, options[:node_group])
        'Success'
      end
    end

    when_rendering :console do |output, _nodename, _options|
      if output.is_a?(String)
        output
      else
        JSON.pretty_generate output
      end
    end
  end

  action :environments do
    summary 'Query environment sync status'
    arguments '[environment]'

    when_invoked do |*args|
      options      = args.last
      environments = classifier.get_environments

      if args.length == 2
        output << environments.select { |g| g['name'] == args.first }
      elsif args.length == 1
        output << environments
      else
        raise("wrong number of arguments (#{args.length - 1} for 1)")
      end
      output.flatten
    end

    when_rendering :console do |output|
      if output.length > 1
        output
      elsif output.first.class == Hash && output.first.has_key?('sync_succeeded')
        output.first['sync_succeeded'].to_s
      else
        raise('Environment doesn\'t exist.')
      end
    end
  end

  def check_facts(file, options)
    if file && options[:explain]
      begin
        contents   = YAML.load_file(file)
        contents ||= JSON.parse(File.read(file))
      rescue
        raise "Could not file file '#{file}'"
      else
        contents
      end
    else
      {}
    end
  end

  def read_import(file)
    contents = JSON.parse(File.read(file))
  rescue
    raise "Could not read file '#{file}'"
  else
    contents
  end

  def cap_class_name(k)
    k.split('::').collect { |p| p.capitalize }.join('::')
  end
end
