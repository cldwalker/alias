require 'g/alias_creator'
require 'test_helper'

context "main" do
  specify "shortest_nonconstant_aliases" do
    expected_hash = {"Yo"=>"Y", "Man"=>"M", "Cool"=>"C", 'Yay'=>'Ya'}
    eval "::Y = 'some value'"
    AliasCreatorI.make_shortest_aliases(['Yo','Yay','Cool','Man'], :constant=>false).should ==
      expected_hash
  end
  
  specify "shortest_constant_aliases" do
    expected_hash = {"Yo"=>"Yo", "Man"=>"M", "Cool"=>"C", 'Yay'=>'Ya'}
    eval "::Y = 'some value'"
    AliasCreatorI.make_shortest_aliases(['Yo','Yay','Cool','Man'], :constant=>true).should ==
      expected_hash
  end
  
  specify "clean_invalid_klass_keys" do
    h1 = {'AliasCreator'=>'whoop','Yay'=>'Haha'}
    AliasCreatorI.clean_invalid_klass_keys(h1)
    h1.should == {'AliasCreator'=>'whoop'}
  end
  
  specify "create_constant_aliases" do
    h1 = {'Time'=>'T'}
    AliasCreatorI.constant_aliases = {}
    AliasCreatorI.create_constant_aliases(h1, :auto_alias=>['Date'])
    AliasCreatorI.constant_aliases.should == {'Time'=>'T','Date'=>'D'}
  end
  
  #didn't test other create_* b/c they're wrappers around forwardable methods
  #td: find* make* methods
end