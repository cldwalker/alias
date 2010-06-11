require File.join(File.dirname(__FILE__), 'test_helper.rb')

describe "Validator" do
  before_all { eval "class ::TestCreator < Alias::Creator; end"}
  before { Validator.instance_eval "@validators = {}"}

  def validate(options={})
    creator = TestCreator.new
    options.each {|k,v| creator.send("#{k}=",v)}
    @validator.validate(creator, {}, :blah)
  end

  def validator_message
    @validator.create_message(:blah)
  end

  def create_validator(options)
    @validator = TestCreator.valid :num, options
  end

  def create_parent_validator(key)
    Validator.register_validators [{:key=>key, :if=>lambda {|e| 'yo'}, :message=>lambda {|e| 'cool'}}]
    @parent_validator = Validator.validators[key]
  end

  it "copies a validator when using a previous one" do
    create_parent_validator :num
    create_validator :if=>:num
    @parent_validator.validate(TestCreator.new, {}, :blah).should == validate
  end

  it "inherits a validator's message when using a previous one" do
    create_parent_validator :num
    create_validator :if=>:num
    validator_message.should == 'cool'
  end

  it "overrides an inherited message with explicit message" do
    create_parent_validator :num
    create_validator :if=>:num, :message=>lambda {|e| 'cooler'}
    validator_message.should == 'cooler'
  end

  it "sets a default message if an invalid one is given" do
    create_validator :if=>lambda {|e| 'yo'}, :message=>:blah
    validator_message.should =~ /Validation failed/
  end

  it "with :with option sets proc arg" do
    create_validator :if=>lambda {|e| 'yo'}, :with=>[:a, :b]
    @validator.validation_proc.expects(:call).with(['a','c'])
    @validator.validate(TestCreator.new, {:a=>'a', :b=>'c', :c=>'d'}, :c)
  end

  it "with :unless option negates result and changes message" do
    create_validator :unless=>lambda {|e| true }, :message=>lambda {|e| "yo doesn't exist"}
    validate.should == false
    validator_message.should == 'yo already exists'
  end

  it "with :optional option can be forced" do
    create_validator :if=>lambda { false }, :optional=>true
    validate(:force=>true).should == true
  end

  it "without :optional option cannot be forced" do
    create_validator :if=>lambda {|e| false }
    validate(:force=>true).should == false
  end
end