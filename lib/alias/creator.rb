# This is the base creator class from which other *Creator classes inherit.
# Methods this class provides to non-creator classes are: Creator.create()
# Methods this class provides to creator classes to be overridden: @creator.delete_invalid_aliases
# and @creator.create_aliases

module Alias
  # TODO: explain default validators, mention :alias exception
  class Creator
    class<<self

      # Creates a validation expectation for the creator with a validator. A validator must be specified with the :if or :unless option.
      # If the validator results in false for an alias, the alias is skipped.
      # ==== Options:
      # [:if] A proc to serve as the validator or a symbol referencing an existing validator. The validator should evaluate to true
      #       for the validation to pass. The validator receives different arguments depending on the key's name.
      #       If the key name is the same as an alias's attribute, then only that current alias attribute is passed. Otherwise, the
      #       alias hash is passed. The :with option overrides what's passed to the validator.
      # [:unless] Same as :if option but the result is negated.
      # [:message] A proc to print a message if the creator's verbose flag is set. Receives same arguments as validator. If a previous
      #            validator is referenced in :unless or :if, then their :message is inherited.
      # [:with]  An array of alias attributes which specifies the current alias attributes to pass the validator
      #          and message procs as an array.
      def valid(key, options={})
        @validators ||= {}
        if (condition = options[:unless] || options[:if])
          condition_proc = Creator.validators[condition] ? Creator.validators[condition].clone : condition
          @validators[key] = options[:unless] ? lambda {|e| ! condition_proc.call(e) } : condition_proc
          unless @validators[key].respond_to?(:call)
            $stderr.puts "Validator not set for #{key}"
            @validators.delete(key)
            return
          end
        else
          raise ArgumentError, "A :unless or :if option is required."
        end
        if options[:message].is_a?(Proc)
          message = options[:unless] ? lambda {|e| options[:message].call(e).gsub("doesn't exist", 'exists') } : options[:message]
          @validators[key].instance_eval("class <<self; self; end").send :define_method, :message, message
        elsif !@validators[key].respond_to?(:message)
          @validators[key].instance_eval %[def self.message(obj); "Validation failed for #{self}'s #{key} since it doesn't exist" ; end]
        end
        if options[:unless]
          @validators[key].instance_eval("class <<self; self; end").send :alias_method, :old_message, :message
          @validators[key].instance_eval("class <<self; self; end").send :define_method, :message, 
            lambda {|e| old_message(e).gsub("doesn't exist", 'exists') }
        end
        @validators[key].instance_eval("class <<self; self; end").send(:define_method, :with, lambda{ options[:with]}) if options[:with]
      end

      #:nodoc:
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
      #:startdoc:
    end

    valid :constant, :if=>lambda {|e| any_const_get(e) }, :message=>lambda {|e| "Constant '#{e}' deleted since it doesn't exist"}
    valid :class, :if=>lambda {|e| ((klass = any_const_get(e)) && klass.is_a?(Module)) },
      :message=>lambda {|e| "Class '#{e}' deleted since it doesn't exist"}
    valid :instance_method, :if=> lambda {|e| instance_method?(*e) },
      :message=>lambda {|e| "#{e[0]}: instance method '#{e[1]}' deleted since it doesn't exist" }
    valid :class_method, :if=>lambda {|e| class_method?(*e) },
      :message=>lambda {|e| "#{e[0]}: class method '#{e[1]}' deleted since it doesn't exist" }

    attr_accessor :verbose, :force, :searched_at, :modified_at, :alias_map
    def initialize(options={})
      self.alias_map = []
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
      self.alias_map = alias_map + aliases_array
      #TODO: create method for efficiently removing constants/methods in any namespace
      silence_warnings { create_aliases(aliases_array) }
    end

    def delete_invalid_aliases(arr)
      arr.delete_if {|e|
        !self.class.validators.select {|k,v| !(k == :alias && self.force)}.all? {|k,v|
          args = v.respond_to?(:with) ? v.with.map {|f| e[f] } : (e[k] || e)
          result = v.call(args)
          puts v.message(args) if result != true && self.verbose
          result
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
