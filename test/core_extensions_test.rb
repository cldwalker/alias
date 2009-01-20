require File.join(File.dirname(__FILE__), 'test_helper.rb')

class CoreExtensionsTest < Test::Unit::TestCase
  test "any_const_get fetches simple class" do
    Object.any_const_get("Array").should == Array
  end
  
  test "any_const_get fetches nested class" do
    eval "module ::Somemodule; class Someclass; end; end"
    Object.any_const_get("Somemodule::Someclass").should == Somemodule::Someclass
  end
  
  test "any_const_get returns nil for nonexistent class" do
    Object.any_const_get("NonexistentClass").should == nil
  end
  
  test "slice only returns valid keys given" do
    {:a=>1, :b=>2}.slice(:a, :c).should == {:a=>1}
  end
  
  test "slice_off! returns given keys but takes them off existing hash" do
    h = {:a=>1, :b=>2}
    h.slice_off!(:a, :c).should == {:a=>1}
    h.should == {:b=>2}
  end
end
