require 'rspec-puppet-utils'

# Uncomment this to show coverage report, also useful for debugging
#at_exit { RSpec::Puppet::Coverage.report! }

RSpec.configure do |c|
  c.mock_with :rspec
  c.mock_framework = :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'
