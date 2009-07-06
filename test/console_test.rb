require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::ConsoleTest < Test::Unit::TestCase
  before(:all) { @console = Object.new.extend(Alias::Console) }
  test "create_aliases doesn't save failed alias creation" do
    capture_stderr { @console.create_aliases :blah, {} }
    Alias.manager.instance_eval("@created_aliases").should == {}
  end

  context "save_aliases" do
    before(:all) { eval "module ::Bluh; def blah; end; end" }
    before(:each) { Alias.manager.instance_eval("@created_aliases = nil") }

    test "saves created aliases" do
      hash = {"Bluh"=>{"blah"=>"bl"}}
      @console.create_aliases :instance_method, hash
      File.expects(:exists?).returns(false)
      Alias.expects(:save_to_file).with("#{ENV['HOME']}/.aliases.yml", {:aliases=>{:instance_method=>hash}}.to_yaml)
      capture_stdout { @console.save_aliases }.should =~ /Save/
    end

    test "saves to given file" do
      hash = {"Bluh"=>{"blah"=>"b"}}
      @console.create_aliases :instance_method, hash
      Alias.expects(:save_to_file).with("explicit", {:aliases=>{:instance_method=>hash}}.to_yaml)
      capture_stdout { @console.save_aliases('explicit') }.should =~ /explicit/
    end

    test "prints message if nothing to save" do
      capture_stdout { @console.save_aliases }.should =~ /Didn't save/
    end

    test "saves aliases to config/aliases.yml if config/ exists" do
      File.expects(:directory?).returns(true)
      @console.create_aliases :instance_method, {"Bluh"=>{"blah"=>"b2"}}
      Alias.expects(:save_to_file).with("config/aliases.yml", anything)
      capture_stdout { @console.save_aliases }
    end

    test "merges existing aliases with created aliases" do
      hash = {"Bluh"=>{"blah"=>"b2"}}
      @console.create_aliases :instance_method, hash
      Alias.expects(:read_config_file).returns({:aliases=>{:instance_method=>{"Bluh"=>{"bling"=>"bl"}}}})
      Alias.expects(:save_to_file).with("#{ENV['HOME']}/.aliases.yml", 
        {:aliases=>{:instance_method=>{"Bluh"=>{'bling'=>'bl', 'blah'=>'b2'}}}}.to_yaml)
      capture_stdout { @console.save_aliases }
    end
  end
end