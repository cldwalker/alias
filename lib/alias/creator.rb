module Alias
  # This is the base creator class. To create a valid creator, a creator must define Alias::Creator.map_config and Alias::Creator.create_aliases.
  # Although not required, creators should enforce validation of their aliases with Alias::Creator.valid.
  class Creator
    class AbstractMethodError < StandardError; end
    class<<self
      attr_reader :validators

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
        begin
          @validators[key] = Validator.new(options.merge(:key=>key, :creator=>self))
        rescue Validator::MissingConditionError
          raise ArgumentError, "A :unless or :if option is required."
        rescue Validator::InvalidValidatorError
          $stderr.puts "Validator not set for #{key}"
          @validators.delete(key)
        end
      end

      def maps_config(config) #:nodoc:
        @map_config ? @map_config.call(config) : raise(AbstractMethodError, "No map_config defined for #{self}")
      end

      # Takes a block which converts the creator's config to an array of aliases.
      def map_config(&block)
        @map_config = block
      end

      def creates_aliases(aliases) #:nodoc:
        @create_aliases ? @create_aliases.call(aliases) : raise(AbstractMethodError, "No create_aliases defined for #{self}")
      end

      # Takes a block which converts aliases to a string of ruby code to run through Kernel#eval.
      def create_aliases(&block)
        @create_aliases = block
      end

      def class_or_module(klass) #:nodoc:
        Util.any_const_get(klass).is_a?(Class) ? 'class' : 'module'
      end
    end

    attr_accessor :verbose, :force, :searched_at, :modified_at, :alias_map

    def initialize(options={})
      self.alias_map = []
      @verbose = false
      @force = options[:force] || false
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
      aliases_array = self.class.maps_config(aliases_hash)
      delete_invalid_aliases(aliases_array)
      self.alias_map = alias_map + aliases_array
      #TODO: create method for efficiently removing constants/methods in any namespace
      Util.silence_warnings {
        eval_string = self.class.creates_aliases(aliases_array)
        eval(eval_string)
      }
    end

    def delete_invalid_aliases(arr)
      arr.delete_if {|aliased|
        !self.class.validators.all? {|attribute, validator|
          validator.validate(self, aliased, attribute)
        }
      }
    end
    
    # Must be overridden to use auto_create()
    def generate_aliases(array_to_alias);
      raise "This abstract method must be overridden."
    end
    
    def to_searchable_array
      self.class.maps_config(@alias_map)
    end
  end
end