require 'hiera-puppet-helper/version'
require 'hiera-puppet-helper/puppet'
require 'hiera-puppet-helper/rspec'

require 'hiera'
require 'puppet/indirector/hiera'

def hiera_stub
  config = Hiera::Config.load(hiera_config)
  config[:logger] = 'puppet'
  Hiera.new(:config => config)
end

RSpec.configure do |c|
  c.mock_framework = :rspec

  c.before(:each) do
    Puppet::Indirector::Hiera.stub(:hiera => hiera_stub)
    # Use this to debug
    #Puppet::Util::Log.level = :debug
    #Puppet::Util::Log.newdestination(:console)
  end

  puts "Use of this module is obsoleted by December 2013 changes to rspec-puppet."
  puts "For guidance please see: "
  puts "http://ask.puppetlabs.com/question/60/what-is-the-recommended-method-for-testing-modules-that-use-hiera/?answer=17865#post-id-17865 "
end

