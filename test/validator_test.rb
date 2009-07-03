require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::ValidatorTest < Test::Unit::TestCase
  context "Validator" do
    before(:all) { eval "class ::TestCreator < Alias::Creator; end"}
    before(:each) { Alias::Validator.instance_eval "@validators = {}"}

    def validate(options={})
      @validator.validate(TestCreator.new(options), {}, :blah)
    end

    def validator_message
      @validator.create_message(:blah)
    end

    def create_validator(options)
      @validator = TestCreator.valid :num, options
    end

    def create_parent_validator(key)
      Alias::Validator.register_validators [{:key=>key, :if=>lambda {|e| 'yo'}, :message=>lambda {|e| 'cool'}}]
      @parent_validator = Alias::Validator.validators[key]
    end

    test "copies a validator when using a previous one" do
      create_parent_validator :num
      create_validator :if=>:num
      @parent_validator.validate(TestCreator.new, {}, :blah).should == validate
    end

    test "inherits a validator's message when using a previous one" do
      create_parent_validator :num
      create_validator :if=>:num
      validator_message.should == 'cool'
    end

    test "overrides an inherited message with explicit message" do
      create_parent_validator :num
      create_validator :if=>:num, :message=>lambda {|e| 'cooler'}
      validator_message.should == 'cooler'
    end

    test "sets a default message if an invalid one is given" do
      create_validator :if=>lambda {|e| 'yo'}, :message=>:blah
      validator_message.should =~ /Validation failed/
    end

    test "with :with option sets proc arg" do
      create_validator :if=>lambda {|e| 'yo'}, :with=>[:a, :b]
      @validator.validation_proc.expects(:call).with(['a','c'])
      @validator.validate(TestCreator.new, {:a=>'a', :b=>'c', :c=>'d'}, :c)
    end

    test "with :unless option negates result and changes message" do
      create_validator :unless=>lambda {|e| true }, :message=>lambda {|e| "yo doesn't exist"}
      validate.should == false
      validator_message.should == 'yo exists'
    end

    test "with :optional option can be forced" do
      create_validator :if=>lambda { false }, :optional=>true
      validate(:force=>true).should == true
    end

    test "without :optional option cannot be forced" do
      create_validator :if=>lambda { false }
      validate(:force=>true).should == false
    end
  end
end