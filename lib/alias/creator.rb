# This is the base creator class from which other *Creator classes inherit.
# Methods this class provides to non-creator classes are: Creator.create()
# Methods this class provides to creator classes to be overridden: @creator.delete_invalid_aliases
# and @creator.create_aliases

module Alias
  class Creator
    class<<self
      def valid(key, options={}, &proc)
        @validators ||= {}
        if (condition = options[:unless] || options[:if])
          condition_proc = condition.is_a?(Symbol) ? superclass.validators[condition] : condition
          @validators[key] = options[:unless] ? lambda {|e| ! condition_proc.call(e) } : condition_proc
          $stderr.puts "No validator set for #{key}" unless @validators[key].respond_to?(:call)
        else
          raise ArgumentError, "A :unless or :if option is required."
        end
      end

      def validators
        @validators
      end

      def any_const_get(klass)
        Creator.class_cache[klass] ||= Util.any_const_get(klass)
      end

      def class_cache
        @class_cache ||= {}
      end

      def instance_method?(klass, method)
        (klass = any_const_get(klass)) && klass.method_defined?(method)
      end

      def class_method?(klass, method)
        (klass = any_const_get(klass)) && klass.respond_to?(method)
      end
    end
    valid :constant, :if=>lambda {|e| any_const_get(e) }
    valid :class, :if=>lambda {|e| ((klass = any_const_get(e)) && klass.is_a?(Module)) }

    attr_accessor :verbose, :force, :searched_at, :modified_at, :alias_map
    def initialize(aliases_hash={})
      self.alias_map = aliases_hash
      @verbose = false
      @force = false
    end
    
    def modified_since_last_search?
      (@searched_at && @modified_at) ? (@modified_at > @searched_at) : true
    end
    
    def alias_map=(value)
      @modified_at = Time.now
      @alias_map = value
    end
    
    def auto_create(array_to_alias)
      aliases_hash = generate_aliases(array_to_alias)
      create(aliases_hash)
      aliases_hash
    end
    
    # Options are:
    # * :auto_alias : Array of constants to alias by shortest available constant. For example,
    #   if the constant A already exists, then Aardvark would be aliased to Aa.
    def manager_create(aliases_hash, options = {})
      self.verbose = options['verbose'] if options['verbose']
      self.force = options['force'] if options['force']
      create(aliases_hash)
      if options['auto_alias']
        auto_create(options['auto_alias'])
      end
    end

    def create(aliases_hash)
      aliases_array = convert_map(aliases_hash)
      delete_invalid_aliases(aliases_array)
      # TODO: self.alias_map = alias_map.merge aliases_hash
      #td: create method for efficiently removing constants/methods in any namespace
      silence_warnings { create_aliases(aliases_array) }
    end

    def delete_invalid_aliases(arr)
      arr.delete_if {|e|
        !self.class.validators.select {|k,v| !(k == :alias && self.force)}.all? {|k,v|
          e.has_key?(k) ? v.call(e[k]) : v.call(e)
        }
      }
    end

    # Must be overridden to use create()
    def convert_map(aliases_hash); 
      raise "This abstract method must be overridden."
    end

    # Must be overridden to use create()
    def create_aliases(aliases_hash); 
      raise "This abstract method must be overridden."
    end
    
    # Must be overridden to use auto_create()
    def generate_aliases(array_to_alias);
      raise "This abstract method must be overridden."
    end
    
    def to_searchable_array
      convert_map(@alias_map)
    end

    private
    def any_const_get(klass)
      Creator.any_const_get(klass)
    end

    def silence_warnings
      old_verbose, $VERBOSE = $VERBOSE, nil
      yield
    ensure
      $VERBOSE = old_verbose
    end
  end
end
