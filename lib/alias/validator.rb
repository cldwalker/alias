module Alias
  # Creates validations declared by Alias::Creator.valid.
  class Validator
    class MissingConditionError < StandardError; end
    class InvalidValidatorError < StandardError; end

    attr_reader :validation_proc, :message
    # Options are describe in Alias::Creator.valid.
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

    # Validates given alias objects. If it returns true, alias object is aliased. Otherwise it's ignored.
    # Prints a message for failed validations if creator has verbose flag set.
    def validate(current_creator, aliased, current_attribute)
      return true if @optional && current_creator.force
      arg = create_proc_arg(aliased, current_attribute)
      result = @validation_proc.call(arg)
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

    def create_proc_arg(aliased, current_attribute) #:nodoc:
      @options[:with] ? @options[:with].map {|f| aliased[f] } : (aliased[current_attribute] || aliased)
    end

    def create_message(arg)
      result = @message.call(arg)
      @options[:unless] ? result.gsub("doesn't exist", 'exists') : result
    end
    #:startdoc:

    class <<self
      attr_reader :validators

      # Registers validators which creators can inherit from.
      def register_validators(validators)
        @validators ||= {}
        validators.each do |e|
          @validators[e[:key]] ||= Validator.new(e.merge(:creator=>self))
        end
      end

      # Default validators are :constant, :class, :instance_method and :class_method .
      def default_validators
        [
          {:key=>:constant, :if=>lambda {|e| any_const_get(e) }, :message=>lambda {|e| "Constant '#{e}' deleted since it doesn't exist"}},
          {:key=>:class, :if=>lambda {|e| ((klass = any_const_get(e)) && klass.is_a?(Module)) },
            :message=>lambda {|e| "Class '#{e}' deleted since it doesn't exist"}},
          {:key=>:instance_method, :if=> lambda {|e| instance_method?(*e) },
            :message=>lambda {|e| "#{e[0]}: instance method '#{e[1]}' deleted since it doesn't exist" }},
          {:key=>:class_method, :if=>lambda {|e| class_method?(*e) },
            :message=>lambda {|e| "#{e[0]}: class method '#{e[1]}' deleted since it doesn't exist" }}
        ]
      end

      #:stopdoc:
      def any_const_get(name)
        Util.any_const_get(name)
      end

      def instance_method?(klass, method)
        (klass = any_const_get(klass)) && klass.method_defined?(method)
      end

      def class_method?(klass, method)
        (klass = any_const_get(klass)) && klass.respond_to?(method)
      end
      #:startdoc:
    end
  end
end
Alias::Validator.register_validators(Alias::Validator.default_validators)