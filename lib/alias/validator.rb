module Alias
  # Creates validations for use with Alias::Creator.valid.
  class Validator
    class MissingConditionError < StandardError; end
    class InvalidValidatorError < StandardError; end

    attr_reader :validation_proc, :message
    # Options are described in Alias::Creator.valid.
    def initialize(options={})
      raise ArgumentError unless options[:key] && options[:creator]
      @condition = options[:if] || options[:unless] || raise(MissingConditionError)
      inherits(Validator.validators[@condition]) if Validator.validators[@condition]
      raise InvalidValidatorError unless @condition.is_a?(Proc)
      @optional = options[:optional] || false
      @validation_proc = options[:unless] ? lambda {|e| ! @condition.clone.call(e) } : @condition
      @options = options
      @message = options[:message] if options[:message]
      @message = default_message unless @message.is_a?(Proc)
    end

    # Validates a given alias hash with the validator proc defined by :if or :unless in Alias::Creator.valid.
    # Default arguments that these procs receive works as follows:
    # If the validation key is the same name as any of the keys in the alias hash, then only the value of that
    # that alias key is passed to the procs. If not, then the whole alias hash is passed.
    def validate(current_creator, alias_hash, current_attribute)
      return true if @optional && current_creator.force
      arg = create_proc_arg(alias_hash, current_attribute)
      result = !!@validation_proc.call(arg)
      puts create_message(arg) if result != true && current_creator.verbose
      result
    end

    #:stopdoc:
    def inherits(parent_validator)
      @condition = parent_validator.validation_proc.clone
      @message = parent_validator.message.clone
    end

    def default_message
      lambda {|e| "Validation failed for #{@options[:creator]}'s #{@options[:key]} since it doesn't exist"}
    end

    def create_proc_arg(alias_hash, current_attribute) #:nodoc:
      @options[:with] ? @options[:with].map {|f| alias_hash[f] } : (alias_hash[current_attribute] || alias_hash)
    end

    def create_message(arg)
      result = @message.call(arg)
      @options[:unless] ? result.gsub("doesn't exist", 'already exists') : result
    end
    #:startdoc:

    class <<self
      # Hash of registered validators.
      attr_reader :validators

      # Registers validators which creators can reference as symbols in Alias::Creator.valid.
      def register_validators(validators)
        @validators ||= {}
        validators.each do |e|
          @validators[e[:key]] ||= Validator.new(e.merge(:creator=>self))
        end
      end

      # Default validators are :constant, :class, :instance_method and :class_method.
      def default_validators
        [
          {:key=>:constant, :if=>lambda {|e| any_const_get(e) }, :message=>lambda {|e| "Constant '#{e}' not created since it doesn't exist"}},
          {:key=>:class, :if=>lambda {|e| ((klass = any_const_get(e)) && klass.is_a?(Module)) },
            :message=>lambda {|e| "Alias for class '#{e}' not created since the class doesn't exist"}},
          {:key=>:instance_method, :if=> lambda {|e| instance_method?(*e) },
            :message=>lambda {|e| "Alias for instance method '#{e[0]}.#{e[1]}' not created since it doesn't exist" }},
          {:key=>:class_method, :if=>lambda {|e| class_method?(*e) },
            :message=>lambda {|e| "Alias for class method '#{e[0]}.#{e[1]}' not created since it doesn't exist" }}
        ]
      end

      #:stopdoc:
      def any_const_get(name)
        Util.any_const_get(name)
      end

      def instance_method?(klass, method)
        (klass = any_const_get(klass)) && (klass.method_defined?(method) || klass.private_method_defined?(method))
      end

      def class_method?(klass, method)
        (klass = any_const_get(klass)) && klass.respond_to?(method, true)
      end
      #:startdoc:
    end
  end
end
Alias::Validator.register_validators(Alias::Validator.default_validators)