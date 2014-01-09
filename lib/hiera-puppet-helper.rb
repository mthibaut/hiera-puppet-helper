require 'hiera-puppet-helper/version'
require 'hiera-puppet-helper/puppet'
require 'hiera-puppet-helper/rspec'

require 'hiera'
require 'puppet/indirector/data_binding/hiera'

def hiera_stub
  config = Hiera::Config.load(hiera_config)
  config[:logger] = 'puppet'
  Hiera.new(:config => config)
end

RSpec.configure do |c|
  c.mock_framework = :rspec

  c.before(:each) do
    Puppet::DataBinding::Hiera.stub(:hiera => hiera_stub)
    # Use this to debug
    #Puppet::Util::Log.level = :debug
    #Puppet::Util::Log.newdestination(:console)
  end

end

