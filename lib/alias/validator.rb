module Alias
  # Creates validations declared by Alias::Creator.valid.
  class Validator
    class MissingConditionError < StandardError; end
    class InvalidValidatorError < StandardError; end

    attr_reader :validation_proc, :message
    # Options are describe in Alias::Creator.valid.
    def initialize(options={})
      @condition = options[:if] || options[:unless] || raise(MissingConditionError)
      inherits(Creator.validators[@condition]) if Creator.validators[@condition]
      raise InvalidValidatorError unless @condition.is_a?(Proc)
      @optional = options[:optional] || false
      @validation_proc = options[:unless] ? lambda {|e| ! @condition.clone.call(e) } : @condition
      @options = options
      @message = options[:message] if options[:message]
      @message = default_message unless @message.is_a?(Proc)
    end

    # Validates given aliasee. If it returns true, aliasee is aliased. Otherwise aliasee is ignored.
    # Prints a message for failed validations if creator has verbose flag set.
    def validate(current_creator, aliasee, current_attribute)
      return true if @optional && current_creator.force
      arg = create_proc_arg(aliasee, current_attribute)
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

    def create_proc_arg(aliasee, current_attribute) #:nodoc:
      @options[:with] ? @options[:with].map {|f| aliasee[f] } : (aliasee[current_attribute] || aliasee)
    end

    def create_message(arg)
      result = @message.call(arg)
      @options[:unless] ? result.gsub("doesn't exist", 'exists') : result
    end
    #:startdoc:
  end
end