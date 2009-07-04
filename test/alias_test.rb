require File.join(File.dirname(__FILE__), 'test_helper.rb')

class AliasTest < Test::Unit::TestCase
  test "loads config file config/aliases.yml if found" do
    File.expects(:exists?).with('config/aliases.yml').returns(true)
    File.expects(:read).returns('')
    Alias.load_config_file
  end
  
  test "loads config file aliases.yml if found" do
    File.stubs(:exists?).returns(false, true)
    File.stubs(:read).returns('')
    Alias.load_config_file
  end
  
  test "loads given config file" do
    config = Alias.load_config_file(File.join(File.dirname(__FILE__),'aliases.yml'))
    assert config.is_a?(Hash)
  end
  
  test "returns hash if no config file found" do
    File.stubs(:exists?).returns(false)
    Alias.load_config_file.should == {}
  end
  
  context "Alias init" do
    before(:each) { Alias.instance_eval "@manager = @config = nil"}
    
    test "sets config properly" do
      Alias.manager.expects(:create_aliases).times(2)
      Alias.init :verbose=>true, :constant=> {'Blah'=>'B'}, :instance_method=>{'String'=>{'to_s'=>'s'}}
      expected_config = {:instance_method=>{"String"=>{"to_s"=>"s"}}, :constant=>{"Blah"=>"B"}, :verbose=>true}
      Alias.config.should == expected_config
    end
    
    test "creates manager object and non-empty aliases" do
      Alias.init :file=>File.join(File.dirname(__FILE__),'aliases.yml')
      Alias.manager.alias_map(:instance_method).empty?.should be(false)
      Alias.manager.alias_map(:class_method).empty?.should be(false)
      Alias.manager.alias_map(:constant).empty?.should be(false)
      Alias.manager.alias_map(:delegate_to_class_method).empty?.should be(false)
    end
    
    test "with verbose option sets config and manager verbosity" do
      Alias.init :verbose=>true, :instance_method=>{}
      assert Alias.config[:verbose]
      assert Alias.manager.verbose
    end
    
    test "with no verbose option doesn't set config and manager verbosity" do
      Alias.manager.stubs(:create_aliases)
      assert Alias.manager.expects(:verbose=).never
      Alias.init
      assert Alias.config[:verbose].nil?
    end
  end
  
end