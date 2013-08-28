require 'puppet'

class Puppet::Parser::Compiler
  alias_method :compile_unadorned, :compile

  def compile
    spec = Thread.current[:spec]

    if spec
      register_function_hiera(spec)
      register_function_hiera_array(spec)
      register_function_hiera_hash(spec)
      register_function_hiera_include(spec)
    end

    compile_unadorned
  end

  def register_function_hiera(spec)
    Puppet::Parser::Functions.newfunction(:hiera, :type => :rvalue) do |*args|
      # Functions called from puppet manifests that look like this:
      # lookup("foo", "bar")
      # internally in puppet are invoked: func(["foo", "bar"])
      #
      # where as calling from templates should work like this:
      # scope.function_lookup("foo", "bar")
      #
      # Therefore, declare this function with args '*args' to accept any number
      # of arguments and deal with puppet's special calling mechanism now:
      if args[0].is_a?(Array)
        args = args[0]
      end

      key = args[0]
      default = args[1]
      override = args[2]

      require 'hiera'
      require 'hiera/scope'

      hiera = Hiera.new(:config => spec.hiera_config.merge(:logger => 'puppet'))

      if self.respond_to?("[]")
        hiera_scope = self
      else
        hiera_scope = Hiera::Scope.new(self)
      end

      answer = hiera.lookup(key, default, hiera_scope, override, :priority)

      raise(Puppet::ParseError, "Could not find data item #{key} in any Hiera data file and no default supplied") if answer.nil?

      return answer
    end
  end

  def register_function_hiera_array(spec)
    Puppet::Parser::Functions.newfunction(:hiera_array, :type => :rvalue) do |*args|
      if args[0].is_a?(Array)
        args = args[0]
      end

      key = args[0]
      default = args[1]
      override = args[2]

      require 'hiera'
      require 'hiera/scope'

      hiera = Hiera.new(:config => spec.hiera_config.merge(:logger => 'puppet'))

      if self.respond_to?("[]")
        hiera_scope = self
      else
        hiera_scope = Hiera::Scope.new(self)
      end

      answer = hiera.lookup(key, default, hiera_scope, override, :array)

      raise(Puppet::ParseError, "Could not find data item #{key} in any Hiera data file and no default supplied") if answer.nil?

      answer
    end
  end

  def register_function_hiera_hash(spec)
    Puppet::Parser::Functions.newfunction(:hiera_hash, :type => :rvalue) do |*args|
      if args[0].is_a?(Array)
        args = args[0]
      end

      raise(Puppet::ParseError, "Please supply a parameter to perform a Hiera lookup") if args.empty?

      key = args[0]
      default = args[1]
      override = args[2]

      require 'hiera'
      require 'hiera/scope'

      hiera = Hiera.new(:config => spec.hiera_config.merge(:logger => 'puppet'))

      if self.respond_to?("{}")
        hiera_scope = self
      else
        hiera_scope = Hiera::Scope.new(self)
      end

      answer = hiera.lookup(key, default, hiera_scope, override, :hash)

      raise(Puppet::ParseError, "Could not find data item #{key} in any Hiera data file and no default supplied") if answer.nil?

      answer
    end
  end

  def register_function_hiera_include(spec)
    Puppet::Parser::Functions.newfunction(:hiera_include) do |*args|
      if args[0].is_a?(Array)
        args = args[0]
      end

      key = args[0]
      default = args[1]
      override = args[2]

      require 'hiera'
      require 'hiera/scope'

      hiera = Hiera.new(:config => spec.hiera_config.merge(:logger => 'puppet'))

      if self.respond_to?("[]")
        hiera_scope = self
      else
        hiera_scope = Hiera::Scope.new(self)
      end

      answer = hiera.lookup(key, default, hiera_scope, override, :array)

      raise(Puppet::ParseError, "Could not find data item #{key} in any Hiera data file and no default supplied") if answer.nil?

      method = Puppet::Parser::Functions.function(:include)
      send(method, answer)
    end
  end
end
