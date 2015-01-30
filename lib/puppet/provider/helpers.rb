class Helpers
   
  def self.data_hash(param_hash, filter=false)
    # Construct JSON string, not JSON object
    data = '{ '
    param_hash.each do |k,v|
      if !filter or filter.include? k
        data += "\"#{k}\": "
        if v.is_a?(String)
          data += "\"#{v}\","
        elsif v.is_a?(Hash)
          data += v.to_s.gsub(/=>/, ':')
          data += ','
        else
          data += "#{v},"
        end
      end
    end
    data = data.gsub(/^(.*),/, '\1 }')
    Puppet.debug data
    data
  end

  def self.get_args(param_hash, filter=false)
    data = '?'
    param_hash.each do |k,v|
      if !filter or filter.include? k
        data += "#{k}=#{v}&"
      end
    end
    data = data.gsub(/^(.*)&/, '\1 }')
    Puppet.debug data
    data
  end

end
