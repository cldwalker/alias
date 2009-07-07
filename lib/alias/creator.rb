module Alias
  class Creators; end
  # This is the base creator class. To create a valid creator, a creator must define Alias::Creator.map and Alias::Creator.generate.
  # Although not required, creators should enforce validation of their aliases with Alias::Creator.valid.
  class Creator
    class AbstractMethodError < StandardError; end
    class FailedAliasCreationError < StandardError; end
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
        begin
          validators[key] = Validator.new(options.merge(:key=>key, :creator=>self))
        rescue Validator::MissingConditionError
          raise ArgumentError, "A :unless or :if option is required."
        rescue Validator::InvalidValidatorError
          $stderr.puts "Validator not set for #{key}"
          @validators.delete(key)
        end
      end

      # Stores validators for class by alias attribute.
      def validators
        @validators ||= {}
      end

      def maps_config(config) #:nodoc:
        @map ? @map.call(config) : raise(AbstractMethodError, "No map() defined for #{self}")
      end

      # Takes a block which converts the creator's config to an array of aliases.
      def map(&block)
        @map = block
      end

      def generates_aliases(aliases) #:nodoc:
        @generate ? @generate.call(aliases) : raise(AbstractMethodError, "No generate() defined for #{self}")
      end

      # Takes a block which converts aliases to a string of ruby code to run through Kernel#eval.
      def generate(&block)
        @generate = block
      end

      def class_or_module(klass) #:nodoc:
        Util.any_const_get(klass).is_a?(Class) ? 'class' : 'module'
      end

      def inherited(subclass) #:nodoc:
        @creators ||= []
        @creators << subclass
      end

      # Array of all Creator subclasses.
      def creators; @creators; end
    end

    attr_accessor :verbose, :force, :aliases

    def initialize(options={})
      @verbose = false
      @force = false
      @aliases = []
    end

    def create(aliases_hash, pretend=false)
      aliases_array = self.class.maps_config(aliases_hash)
      delete_invalid_aliases(aliases_array)
      self.aliases = aliases + aliases_array unless pretend
      begin
        #td: create method for efficiently removing constants/methods in any namespace
        eval_string = Util.silence_warnings { self.class.generates_aliases(aliases_array) }
        pretend ? puts("\n", eval_string) : Kernel.eval(eval_string)
      rescue
        raise FailedAliasCreationError, $!
      end
    end

    def delete_invalid_aliases(arr)
      arr.delete_if {|alias_hash|
        !self.class.validators.all? {|attribute, validator|
          validator.validate(self, alias_hash, attribute)
        }
      }
    end
  end
end