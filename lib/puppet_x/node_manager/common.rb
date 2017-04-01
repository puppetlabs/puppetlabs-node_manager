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
    newhash = data.sort.to_h if data.is_a?(Hash)
    newhash.each do |k,v|
      if v.is_a?(Hash)
        newhash[k] = sort_hash(v)
      end
    end
    newhash
  end
end
