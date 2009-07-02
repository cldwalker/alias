require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::CreatorTest < Test::Unit::TestCase
  context "Creator" do
    before(:each) { @creator = Alias::Creator.new}
    test "sets modified_at timestamp when creating aliases" do
      stub_time = Time.new
      Time.expects(:now).returns(stub_time)
      @creator.expects(:create_aliases)
      @creator.expects(:convert_map).returns([])
      @creator.create({})
      @creator.modified_at.should == stub_time
    end
    
    test "with modified_at > searched_at has been modified_since_last_search?" do
      some_time = Time.new
      @creator.modified_at = some_time + 100
      @creator.searched_at = some_time
      assert @creator.modified_since_last_search?
    end
    
    test "with modified_at greater than searched_at has been modified_since_last_search?" do
      some_time = Time.new
      @creator.modified_at = some_time + 100
      @creator.searched_at = some_time
      assert @creator.modified_since_last_search?
    end
    
    test "with modified_at less than searched_at has not been modified_since_last_search?" do
      some_time = Time.new
      @creator.modified_at = some_time
      @creator.searched_at = some_time + 100
      assert !@creator.modified_since_last_search?
    end
    
    test "with no searched_at has been modified_since_last_search?" do
      @creator.modified_at = Time.new
      @creator.searched_at = nil
      assert @creator.modified_since_last_search?
    end
    
    test "sets modified_at when calling alias_map=" do
      stub_time = Time.new
      Time.expects(:now).returns(stub_time)
      @creator.alias_map = {'blah'=>'b'}
      @creator.modified_at.should == stub_time
    end
  end

  context "valid" do
    before(:all) { eval "class ::TestCreator < Alias::Creator; end"}
    before(:each) { Alias::Creator.instance_eval "@validators = {}"}

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
      @parent_validator = Alias::Creator.valid key, :if=>lambda {|e| 'yo'}, :message=>lambda {|e| 'cool'}
    end

    test "raises ArgumentError when no validator is given" do
      assert_raises(ArgumentError) { TestCreator.valid :name }
    end

    test "prints error and deletes validator when invalid one is given" do
      capture_stderr { TestCreator.valid(:name, :if=>:blah) }.should =~ /not set/
      TestCreator.validators[:name].should == nil
    end

    test "copies a validator when using a previous one" do
      create_parent_validator :num
      create_validator :if=>:num
      @parent_validator.validate(Alias::Creator.new, {}, :blah).should == validate
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
