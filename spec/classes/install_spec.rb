require 'spec_helper'
require 'shared_contexts'

describe 'node_manager::install', :type => :class do
  # by default the hiera integration uses hirea data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera


  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {
      :puppetversion => '3.8.0'
    }
  end
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      #:version => 0.1.0,
      #:node_manager_params_do_noop => false,
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  it do
    is_expected.to contain_package('puppetclassify').
             with({"ensure"=>"0.1.0",
                   "provider"=>"puppet_gem",
                   "noop"=>"false"})
  end
end
