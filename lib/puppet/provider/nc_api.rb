class Puppet::Provider::Nc_api < Puppet::Provider
   
  def self.rest(method, endpoint, data=false)

    resp = Helpers.rest_helper(method, endpoint, {'app' => 'classifier-api', 'data' => data})

    case resp.code
    when '200','204'
      resp.body
    when '201'
      info "New environment created as #{resp.body}"
      resp.body
    when '303'
      info "Added #{resp['Location']} to #{endpoint}"
      resp.body 
    when '422'
      jresp = JSON.parse(resp.body)
      debug_message = "#{jresp['kind']}: "
      jresp['details'].each do |k,detail|
        debug_message += "#{k}: #{value} "
      end
      debug debug_message
      fail jresp['kind']
    else
      fail "#{resp.code}: #{resp.message}\n#{resp.body}"
      jresp = JSON.parse(resp.body)
      debug jresp['kind']
    end
  end

end
