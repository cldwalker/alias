require File.join(File.dirname(__FILE__), 'test_helper.rb')

module Alias
  class CreatorTest < Test::Unit::TestCase
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
