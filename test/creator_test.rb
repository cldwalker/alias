require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::CreatorTest < Test::Unit::TestCase
  test "Creator deletes invalid class keys" do
    h1 = {'Alias::Creator'=>'whoop','Yay'=>'Haha'}
    @creator = Alias::Creator.new
    @creator.delete_invalid_class_keys(h1)
    h1.should == {'Alias::Creator'=>'whoop'}
  end
  
  context "Creator" do
    before(:each) { @creator = Alias::Creator.new}
    test "calls delete_existing_aliases when no force" do
      @creator.force = false
      @creator.expects(:delete_existing_aliases)
      @creator.expects(:create_aliases)
      @creator.create({})
    end
    
    test "doesn't call delete_existing_aliases when force" do
      @creator.force = true
      @creator.expects(:delete_existing_aliases).never
      @creator.expects(:create_aliases)
      @creator.create({})
    end
    
    test "sets modified_at timestamp when creating aliases" do
      stub_time = Time.new
      Time.expects(:now).returns(stub_time)
      @creator.expects(:create_aliases)
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
end
