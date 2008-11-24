require 'g/object'
require 'test_helper'
require 'g/class'

context "misc" do
  specify "any_const_get" do
    Object.any_const_get("Array").should == Array
    eval "module Somemodule; class Someclass; end; end"
    Object.any_const_get("Somemodule::Someclass").should == Somemodule::Someclass
    Object.any_const_get("NonexistentClass").should == nil
  end
end