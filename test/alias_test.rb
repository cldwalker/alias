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
  
  test "setup creates creator object and given aliases" do
    Alias.setup :file=>File.join(File.dirname(__FILE__),'aliases.yml')
    Alias.creator.instance_aliases.empty?.should_not be(true)
    Alias.creator.klass_aliases.empty?.should_not be(true)
    Alias.creator.constant_aliases.empty?.should_not be(true)
  end
  
end