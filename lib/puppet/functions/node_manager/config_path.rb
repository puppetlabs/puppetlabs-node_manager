Puppet::Functions.create_function(:'node_manager::config_path') do
  dispatch :nm_yaml_location do
  end

  def nm_yaml_location()
    File.join(Puppet.settings['confdir'], 'node_manager.yaml')
  end
end
