require File.join(File.dirname(__FILE__), 'test_helper.rb')

module Alias
  class CreatorTest < Test::Unit::TestCase
    context "Creator" do
      before(:each) { @creator = Creator.new}
      test "sets modified_at timestamp when creating aliases" do
        stub_time = Time.new
        Time.expects(:now).returns(stub_time)
        @creator.class.expects(:creates_aliases).returns('')
        @creator.class.expects(:maps_config).returns([])
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

    context "invalid creator" do
      before(:all) { eval "class Alias::TestCreator < Alias::Creator; end"}
      test "raises AbstractMethodError if map_config not defined" do
        assert_raises(Creator::AbstractMethodError) {
          TestCreator.maps_config({})
        }
      end

      test "raises AbstractMethodError if create_aliases not defined" do
        assert_raises(Creator::AbstractMethodError) {
          TestCreator.creates_aliases([])
        }
      end

      test "raises ArgumentError when no validator is given" do
        assert_raises(ArgumentError) { TestCreator.valid :name }
      end

      test "prints error and deletes validator when invalid one is given" do
        capture_stderr { TestCreator.valid(:name, :if=>:blah) }.should =~ /not set/
        TestCreator.validators[:name].should == nil
      end
    end
  end
end
