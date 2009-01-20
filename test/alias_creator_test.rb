require File.join(File.dirname(__FILE__), 'test_helper.rb')

class AliasCreatorTest < Test::Unit::TestCase
  context "Make shortest aliases" do
    before(:all) { eval "::Y = 'some value'" }
    before(:each) { @creator = Alias::ConstantCreator.new}
    
    test "without constant checks" do
      expected_hash = {"Yo"=>"Y", "Man"=>"M", "Cool"=>"C", 'Yay'=>'Ya'}
      @creator.make_shortest_aliases(['Yo','Yay','Cool','Man'], :constant=>false).should == expected_hash
    end
   
    test "with constant checks" do
      expected_hash = {"Yo"=>"Yo", "Man"=>"M", "Cool"=>"C", 'Yay'=>'Ya'}
      @creator.make_shortest_aliases(['Yo','Yay','Cool','Man'], :constant=>true).should == expected_hash
    end
  end
  
  test "Creator cleans invalid class keys" do
    h1 = {'Alias::Creator'=>'whoop','Yay'=>'Haha'}
    @creator = Alias::Creator.new
    @creator.clean_invalid_class_keys(h1)
    h1.should == {'Alias::Creator'=>'whoop'}
  end
    
  test "ClassMethodCreator cleans invalid class method keys" do
    h1 = {'String'=>{'to_s'=>'ts'},'Array'=>{'blah'=>'bl'}}
    @creator = Alias::ClassMethodCreator.new
    @creator.clean_invalid_class_method_keys(h1)
    h1.should == {"Array"=>{}, "String"=>{"to_s"=>"ts"}}
  end
  
  test "InstanceMethodCreator cleans invalid instance method keys" do
    h1 = {'String'=>{'strip'=>'st'},'Array'=>{'blah', 'bl'}}
    @creator = Alias::InstanceMethodCreator.new
    @creator.clean_invalid_instance_method_keys(h1)
    h1.should == {"Array"=>{}, "String"=>{"strip"=>"st"}}
  end
  
end