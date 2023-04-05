module PuppetX; end
module PuppetX::Node_manager; end

module PuppetX::Node_manager::Common
  # Transform the node group array in to a hash
  # with a key of the name and an attribute
  # hash of the rest.
  def self.hashify_group_array(group_array)
    hashified = Hash.new

    group_array.each do |group|
      hashified[group['name']] = group
    end

    hashified
  end

  def self.sort_hash(data)
    newhash = Hash.new
    if data.is_a?(Hash)
      # .to_h method doesn't exist until Ruby 2.1.x
      data.sort.flatten(1).each_slice(2) { |a,b| newhash[a] = b }
    end
    newhash.each do |k,v|
      if v.is_a?(Hash)
        newhash[k] = sort_hash(v)
      else
        newhash[k] = v
      end
    end
    newhash
  end

  # check for fact rules in deep array
  def self.factcheck(rulecheck)
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
end
