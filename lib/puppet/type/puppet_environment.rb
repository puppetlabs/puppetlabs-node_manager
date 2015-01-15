Puppet::Type.newtype(:puppet_environment) do
  desc 'The puppet_environment type creates and manages environments for the PE Node Manager'
  ensurable
  newparam(:name, :namevar => true) do
    desc 'This is the name of the environment'
    validate do |value|
      fail("#{name} is not a valid group name") unless value =~ /^[a-zA-Z0-9\-\_'\s]+$/
    end
  end
end
