# Hiera::Puppet::Helper

[![Build Status](https://travis-ci.org/mthibaut/hiera-puppet-helper.png?branch=master)](https://travis-ci.org/mthibaut/hiera-puppet-helper)

Hiera fixtures for puppet-rspec tests.

## Installation

Add this line to your application's Gemfile:

    gem 'hiera-puppet-helper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hiera-puppet-helper

## Usage

Note: you can find a working example inside the example/ directory of this gem.

### Basic

The following assumes that you are already be familiar with
[rspec-puppet](https://github.com/rodjek/rspec-puppet/).

To use this gem add the following include to spec/spec\_helper.rb:

    require 'hiera-puppet-helper'

For the purpose of demonstrating a Hiera fixture, lets assume there is the
following contrived example of a Puppet class:

  _modules/example/manifests/init.pp_

    class example {
      notify { 'foo': message => hiera('foo_message') }
    }

In your specs for this class you can define a Hiera fixture by setting
'hiera\_data' to a hash that contains the data that you want the Puppet
'hiera' function to return:

  _spec/classes/example\_spec.rb_

    describe "example" do
      let(:hiera_data) { { :foo_message => "bar" } }

      it { should contain_notify("foo").with_message("bar") }
    end

### Advanced

It is possible to load the hiera fixtures with any Hiera backend, just define
a method 'hiera\_config' that returns the desired Hiera configuration. For a
list of possible configuration options, see
[https://github.com/puppetlabs/hiera#configuration](https://github.com/puppetlabs/hiera#configuration).

The following example spec loads the Hiera fixture data from Yaml files:

  _spec/classes/example\_spec.rb_

    describe "example" do
      let(:hiera_config) do
        { :backends => ['yaml'],
          :hierarchy => [
            '%{fqdn}/%{calling_module}',
            '%{calling_module}'],
          :yaml => {
            :datadir => File.expand_path(File.join(__FILE__, '..', '..', 'hieradata')) }}
      end

      it { should contain_notify("foo").with_message("bar") }
    end

Be aware that setting 'hiera\_config' takes precedence before setting
'hiera\_data', meaning with the above Hiera configuration, the value of
'hiera\_data' will be ignored. The next example will demonstrate how to address
that.

If you want a combination of fixture data from Yaml files and fixture data from
'hiera\_data', you can use the Hiera 'rspec' backend, which is also provided
by this gem. The 'rspec' backend uses its configuration hash as data store to
look up data. The following example combine both the 'rspec' backend, and the
'yaml' backend, with the effect that the data is first looked up in the
'hiera\_data' fixture defined by the spec and then in Yaml files as well:

  _spec/classes/example\_spec.rb_

    describe "example" do
      let(:hiera_config) do
        { :backends => ['rspec', 'yaml'],
          :hierarchy => [
            '%{fqdn}/%{calling_module}',
            '%{calling_module}'],
          :yaml => {
            :datadir => File.expand_path(File.join(__FILE__, '..', '..', 'hieradata')) },
          :rspec => respond_to?(:hiera_data) ? hiera_data : {} }
      end

      it { should contain_notify("foo").with_message("bar") }
    end

To avoid having to copy-paste the Hiera configuration into each and every spec,
you can use a shared context. The following is a full-featured example that
demonstrates the use of a shared context.

  _spec/spec\_helper.rb_

    require 'hiera-puppet-helper'

    fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

    shared_context "hieradata" do
      let(:hiera_config) do
        { :backends => ['rspec', 'yaml'],
          :hierarchy => [
            '%{fqdn}/%{calling_module}',
            '%{calling_module}'],
          :yaml => {
            :datadir => File.join(fixture_path, 'hieradata') },
          :rspec => respond_to?(:hiera_data) ? hiera_data : {} }
      end
    end

  _spec/classes/example\_spec.rb_

    describe "example" do
      include_context "hieradata"

      it { should contain_notify("foo").with_message("bar") }
    end
