module Alias
  class Validator
    class MissingConditionError < StandardError; end
    class InvalidValidatorError < StandardError; end

    attr_reader :validation_proc, :message
    def initialize(options={})
      condition = options[:if] || options[:unless] || raise(MissingConditionError)
      @parent_validator = Creator.validators[condition]
      condition_proc = @parent_validator ? @parent_validator.validation_proc.clone : condition
      raise InvalidValidatorError unless condition_proc.is_a?(Proc)
      @validation_proc = options[:unless] ? lambda {|*e| ! condition_proc.call(*e) } : condition_proc
      @options = options
      @message = @parent_validator ? @parent_validator.message.clone :
         lambda {|e| "Validation failed for #{@options[:creator]}'s #{@options[:key]} since it doesn't exist"}
      @message = options[:message] if options[:message].is_a?(Proc)
    end

    def validate(current_creator, aliasee, current_attribute)
      arg = create_proc_arg(aliasee, current_attribute)
      result = @validation_proc.call(arg)
      puts create_message(arg) if result != true && current_creator.verbose
      result
    end

    def create_proc_arg(aliasee, current_attribute)
      @options[:with] ? @options[:with].map {|f| aliasee[f] } : (aliasee[current_attribute] || aliasee)
    end

    def create_message(arg)
      result = @message.call(arg)
      @options[:unless] ? result.gsub("doesn't exist", 'exists') : result
    end
  end
end