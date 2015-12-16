require 'puppet/util/node_groups'

Puppet::Type.type(:node_group).provide(:puppetclassify) do
  confine :feature => :puppetclassify

  def initialize(value={})
    super(value)
    @property_flush = {
      'state' => {},
      'attrs' => {},
    }
  end


  def self.classifier
    @classifier ||= initialize_client
  end

  def self.initialize_client
    Puppet::Util::Node_groups.new
  end

  # API will fail if disallowed-keys are passed
  # Decided to use override_environment instead
  def self.friendly_name
    {
      :classes            => 'classes',
      :environment        => 'environment',
      :environment_trumps => 'override_environment',
      :id                 => 'id',
      :name               => 'name',
      :parent             => 'parent',
      :rule               => 'rule',
      :variables          => 'variables'
    }
  end

  def self.instances
    $ngs = classifier.groups.get_groups
    $ngs.collect do |group|
      ngs_hash = {}
      friendly_name.each do |property,friendly|
        # Replace parent ID with string name
        if friendly == 'parent'
          gindex = get_name_index_from_id(group[property.to_s])
          ngs_hash[friendly.to_sym] = $ngs[gindex]['name']
        else
          ngs_hash[friendly.to_sym] = group[property.to_s]
        end
      end
      # Boolean strings converted to syms
      ngs_hash[:override_environment] = :"#{ngs_hash[:override_environment]}"
      ngs_hash[:ensure] = :present
      new(ngs_hash)
    end
  end

  def self.prefetch(resources)
    ngs = instances
    resources.keys.each do |group|
      if provider = ngs.find{ |g| g.name == group }
        resources[group].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  mk_resource_methods

  def create
    @noflush = true
    # Only passing parameters that are given
    send_data = Hash.new
    @resource.original_parameters.each do |k,v|
      next if k == :ensure
      next if @resource.parameter(k).metaparam?
      key = k.to_s
      # key changed for usability
      key = 'environment_trumps' if key == 'override_environment'
      send_data[key] = v
    end
    # namevar may not be in this hash
    send_data['name'] = @resource[:name] unless send_data['name']
    # Passing an empty hash in the type results in undef
    send_data['classes'] = {} unless send_data['classes']

    send_data['parent'] = '00000000-0000-4000-8000-000000000000' if !send_data['parent']
    unless send_data['parent'] =~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
      gindex = get_id_index_from_name(send_data['parent'])
      if gindex
        send_data['parent'] = $ngs[gindex]['id']
      end
    end

    resp = self.class.classifier.groups.create_group(send_data)
    if resp
      @resource.original_parameters.each_key do |k|
        if k == :ensure
          @property_hash[:ensure] = :present
        else
          @property_hash[k]       = @resource[k]
        end
      end
      # Add placeholder for $ngs lookups
      $ngs << { "name" => send_data['name'], "id" => resp }
    else
      fail("puppetclassify was not able to create group")
    end

    exists? ? (return true) : (return false)

  end

  def destroy
    @noflush = true
    begin
      self.class.classifier.groups.delete_group(@property_hash[:id])
    rescue Exception => e
      fail(e.message)
      debug(e.backtrace.inspect)
    else
      @property_hash.clear
    end
    exists? ? (return false) : (return true)
  end

  # If ID is given, translate to string name
  def parent
    if @resource[:parent] =~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
      gindex = self.class.get_name_index_from_id(@resource[:parent])
      $ngs[gindex]['name']
    else
      @property_hash[:parent]
    end
  end

  friendly_name.each do |property,friendly|
    define_method "#{friendly}=" do |value|
      if property == :parent
        if value =~ /^[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}$/
          @property_flush['attrs'][property.to_s] = value
        else
          gindex = $ngs.index { |i| i['name'] == value }
          @property_flush['attrs'][property.to_s] = $ngs[gindex]['id']
        end
      else
        # The to_json function needs to recognize
        # booleans true/false, not symbols :true/false
        case value
        when :true
          @property_flush['attrs'][property.to_s] = true
        when :false
          @property_flush['attrs'][property.to_s] = false
        else
          @property_flush['attrs'][property.to_s] = value
        end
      end
      @property_hash[friendly.to_sym] = value
    end
  end

  def flush
    return if @noflush
    debug @property_flush['attrs']
    if @property_flush['attrs']
      @property_flush['attrs']['id'] = @property_hash[:id] unless @property_flush['attrs']['id']
      begin
        self.class.classifier.groups.update_group(@property_flush['attrs'])
      rescue Exception => e
        fail(e.message)
        debug(e.backtrace.inspect)
      else
      end
    end
  end

  private

  def self.get_name_index_from_id(id)
    $ngs.index { |i| i['id'] == id }
  end

  def get_id_index_from_name(name)
    $ngs.index { |i| i['name'] == name }
  end

end
