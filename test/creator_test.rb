require File.join(File.dirname(__FILE__), 'test_helper.rb')

describe "invalid creator" do
  before_all { eval "class Alias::TestCreator < Alias::Creator; end"}
  it "raises AbstractMethodError if map not defined" do
    should.raise(Creator::AbstractMethodError) {
      TestCreator.maps_config({})
    }
  end

  it "raises AbstractMethodError if generate not defined" do
    should.raise(Creator::AbstractMethodError) {
      TestCreator.generates_aliases([])
    }
  end

  it "raises ArgumentError when no validator is given" do
    should.raise(ArgumentError) { TestCreator.valid :name }
  end

  it "prints error and deletes validator when invalid one is given" do
    capture_stderr { TestCreator.valid(:name, :if=>:blah) }.should =~ /not set/
    TestCreator.validators[:name].should == nil
  end
end