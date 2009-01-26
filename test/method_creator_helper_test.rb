require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::MethodCreatorHelperTest < Test::Unit::TestCase
  
  context "ClassMethodCreator" do
    before(:each) { @creator = Alias::ClassMethodCreator.new }
    
    test "deletes invalid class method keys" do
      h1 = {'String'=>{'yaml_new'=>'yn'},'Array'=>{'blah'=>'bl'}}
      @creator.delete_invalid_method_keys(h1)
      h1.should == {"Array"=>{}, "String"=>{'yaml_new'=>'yn'}}
    end
  
    test "deletes existing class method aliases" do
      h1 = {'Date'=>{'civil_to_jd'=>'civil', 'valid_time?'=>'vt'} }
      @creator.delete_existing_method_aliases(h1)
      h1.should == {'Date'=>{'valid_time?'=>'vt'} }
    end
  
    test "deletes existing class method unless it was created by the object" do
      h1 = {'String'=>{'name'=>'n'}}
      @creator.create(h1)
      assert_not_equal 'blah', String.n
      h2 = {'String'=>{'new'=>'n'}}
      @creator.create(h2)
      assert_equal 'blah', String.n('blah')
    end
    
    test "to_searchable_array is an array of hashes" do
      @creator.alias_map = {'String'=>{'name'=>'n'}}
      @creator.to_searchable_array.should == [{:name=>'name', :alias=>'n', :class=>'String'}]
    end
  end
  
  context "InstanceMethodCreator" do
    before(:each) { @creator = Alias::InstanceMethodCreator.new }
    
    test "deletes existing instance method aliases" do
      h1 = {'String'=>{'strip'=>'st', 'chomp'=>'chop'}}
      @creator.delete_existing_method_aliases(h1)
      h1.should == {"String"=>{"strip"=>"st"}}
    end
    
    test "deletes existing instance method unless it was created by the object" do
      h1 = {'String'=>{'downcase'=>'d'}}
      @creator.create(h1)
      assert_not_equal 'bh', 'blah'.d
      h2 = {'String'=>{'delete'=>'d'}}
      @creator.create(h2)
      assert_equal 'bh', 'blah'.d('la')
    end
  
    test "deletes invalid instance method keys" do
      h1 = {'String'=>{'strip'=>'st'},'Array'=>{'blah', 'bl'}}
      @creator.delete_invalid_method_keys(h1)
      h1.should == {"Array"=>{}, "String"=>{"strip"=>"st"}}
    end
  end
end
