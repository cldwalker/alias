require File.join(File.dirname(__FILE__), 'test_helper.rb')

describe "Util" do
  it "any_const_get fetches simple class" do
    Util.any_const_get("Array").should == Array
  end

  it "any_const_get fetches nested class" do
    eval "module ::Somemodule; class Someclass; end; end"
    Util.any_const_get("Somemodule::Someclass").should == Somemodule::Someclass
  end

  it "any_const_get returns nil for nonexistent class" do
    Util.any_const_get("NonexistentClass").should == nil
  end

  it "slice only returns valid keys given" do
    Util.slice({:a=>1,:b=>2}, :a, :c).should == {:a=>1}
  end

  it "slice_off! returns given keys but takes them off existing hash" do
    h = {:a=>1, :b=>2}
    Util.slice_off!(h, :a, :c).should == {:a=>1}
    h.should == {:b=>2}
  end

  it "camelize should uppercase non-underscored string" do
    Util.camelize('man').should == 'Man'
  end

  it "camelize should camelize underscored string" do
    Util.camelize('some_test').should == 'SomeTest'
  end

  it "make_shortest_aliases" do
    eval "::Y = 'some value'"
    expected_hash = {"Yo"=>"Y", "Man"=>"M", "Cool"=>"C", 'Yay'=>'Ya'}
    Util.make_shortest_aliases(['Yo','Yay','Cool','Man']).should == expected_hash
  end
end