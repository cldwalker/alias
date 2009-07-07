module Alias
  # Namespace for subclasses of Alias::Creator.
  class Creators; end
  # This is the base creator class. To be a valid subclass, the creator must define Alias::Creator.map and Alias::Creator.generate.
  # Although not required, creators should enforce validation of their aliases with Alias::Creator.valid. Also, the creator should
  # be named in the format Alias::Creators::*Creator where the asterisk stands for any unique string. Since that string is converted
  # to an underscored version when referenced in the console, it's recommended to make it camel case. For example,
  # Alias::Creators::InstanceMethodCreator is referenced by it's underscored version :instance_method.
  # 
  # To better understand how a creator works, here's the steps a creator goes through when creating aliases:
  # * map() : Maps the hash from a config file or console input into an array of alias hashes.
  # * valid() : Defines a validation that each alias hash must pass.
  # * generate() : Given the array of alias hashes, generates the string of ruby code to be evaled for alias creation.
  class Creator
    class AbstractMethodError < StandardError; end
    class FailedAliasCreationError < StandardError; end
    class<<self
      # Creates a validation expectation for the creator by giving it an Alias::Validator object aka validator. 
      # This method must be given an :if or :unless option. If the :if option returns false or :unless option
      # returns true for an alias, the alias is skipped.
      # ==== Options:
      # [:if] Takes a proc or a symbol referencing a registered validator. This proc must evaluate to true
      #       for the validation to pass. See Alias::Validator.validate for what arguments this proc receives by default. See
      #       Alias::Validator.default_validators for validators that can be referenced by symbol.
      # [:unless] Same as :if option but the result is negated.
      # [:message] A proc to print a message if the creator's verbose flag is set. Receives same arguments as :if and :unless procs. 
      #            If a previous validator is referenced in :unless or :if, then their :message is inherited.
      # [:with]  An array of alias attributes/keys which specify the current alias attributes to pass to the validator procs.
      #          Overrides default argument a validator proc receives.
      # [:optional] When set to true, this option can be overridden in conjunction with a creator's force flag. Default is false.
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

      # Stores validators per alias attribute/key.
      def validators #:nodoc:
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

    # Same purpose as Alias::Manager.verbose and Alias::Manager.force but unlike them these only take a boolean.
    attr_accessor :verbose, :force
    # Array of alias hashes that have been created.
    attr_accessor :aliases

    def initialize(options={}) #:nodoc:
      @verbose = false
      @force = false
      @aliases = []
    end

    # Main method used to create aliases. Handles mapping, validation and creation of aliases.
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

    # Deletes invalid alias hashes that fail defined validators for a creator.
    def delete_invalid_aliases(arr)
      arr.delete_if {|alias_hash|
        !self.class.validators.all? {|attribute, validator|
          validator.validate(self, alias_hash, attribute)
        }
      }
    end
  end
end