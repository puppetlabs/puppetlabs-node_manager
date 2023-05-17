module PuppetX; end

module PuppetX::Node_manager; end

module PuppetX::Node_manager::Common
  # Transform the node group array in to a hash
  # with a key of the name and an attribute
  # hash of the rest.
  def self.hashify_group_array(group_array)
    hashified = {}

    group_array.each do |group|
      hashified[group['name']] = group
    end

    hashified
  end

  def self.sort_hash(data)
    newhash = {}
    if data.is_a?(Hash)
      # .to_h method doesn't exist until Ruby 2.1.x
      data.sort.flatten(1).each_slice(2) { |a, b| newhash[a] = b }
    end
    newhash.each do |k, v|
      newhash[k] = if v.is_a?(Hash)
                     sort_hash(v)
                   else
                     v
                   end
    end
    newhash
  end

  # check for fact rules in deep array
  def self.factcheck(rulecheck)
    rulecheck.each_with_index do |x, i|
      if (x == 'fact') && (i == 0)
        return true
      end
      next unless x.is_a?(Array)
      if factcheck(x)
        return true
      end
    end
    false
  end
end
