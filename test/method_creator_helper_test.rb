require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::MethodCreatorHelperTest < Test::Unit::TestCase
  
  test "ClassMethodCreator deletes invalid class method keys" do
    h1 = {'String'=>{'yaml_new'=>'yn'},'Array'=>{'blah'=>'bl'}}
    @creator = Alias::ClassMethodCreator.new
    @creator.delete_invalid_method_keys(h1)
    h1.should == {"Array"=>{}, "String"=>{'yaml_new'=>'yn'}}
  end
  
  test "ClassMethodCreator deletes existing class method aliases" do
    h1 = {'Date'=>{'civil_to_jd'=>'civil', 'valid_time?'=>'vt'} }
    @creator = Alias::ClassMethodCreator.new
    @creator.delete_existing_method_aliases(h1)
    h1.should == {'Date'=>{'valid_time?'=>'vt'} }
  end

  test "InstanceMethodCreator deletes existing instance method aliases" do
    h1 = {'String'=>{'strip'=>'st', 'chomp'=>'chop'}}
    @creator = Alias::InstanceMethodCreator.new
    @creator.delete_existing_method_aliases(h1)
    h1.should == {"String"=>{"strip"=>"st"}}
  end
  
  test "InstanceMethodCreator deletes invalid instance method keys" do
    h1 = {'String'=>{'strip'=>'st'},'Array'=>{'blah', 'bl'}}
    @creator = Alias::InstanceMethodCreator.new
    @creator.delete_invalid_method_keys(h1)
    h1.should == {"Array"=>{}, "String"=>{"strip"=>"st"}}
  end

end
