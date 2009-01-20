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
  
  context "Alias_init" do
    before(:each) { Alias.config = {}}
    test "creates manager object and non-empty aliases" do
      Alias.init :file=>File.join(File.dirname(__FILE__),'aliases.yml')
      Alias.manager.instance_aliases.empty?.should_not be(true)
      Alias.manager.klass_aliases.empty?.should_not be(true)
      Alias.manager.constant_aliases.empty?.should_not be(true)
    end
    
    test "with verbose option sets config and manager verbosity" do
      Alias.manager.stubs(:create_aliases)
      Alias.init :verbose=>true
      assert Alias.config['verbose']
      assert Alias.manager.verbose
    end
    
    test "with no verbose option doesn't set config and manager verbosity" do
      Alias.manager.stubs(:create_aliases)
      assert Alias.manager.expects(:verbose=).never
      Alias.init
      assert Alias.config['verbose'].nil?
    end
  end
  
end