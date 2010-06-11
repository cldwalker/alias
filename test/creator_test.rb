require File.join(File.dirname(__FILE__), 'test_helper.rb')

module Alias
describe "invalid creator" do
  before_all { eval "class Alias::TestCreator < Alias::Creator; end"}
  test "raises AbstractMethodError if map not defined" do
    should.raise(Creator::AbstractMethodError) {
      TestCreator.maps_config({})
    }
  end

  test "raises AbstractMethodError if generate not defined" do
    should.raise(Creator::AbstractMethodError) {
      TestCreator.generates_aliases([])
    }
  end

  test "raises ArgumentError when no validator is given" do
    should.raise(ArgumentError) { TestCreator.valid :name }
  end

  test "prints error and deletes validator when invalid one is given" do
    capture_stderr { TestCreator.valid(:name, :if=>:blah) }.should =~ /not set/
    TestCreator.validators[:name].should == nil
  end
end
end