require File.join(File.dirname(__FILE__), 'test_helper.rb')

describe "Console" do
  before { @console = nil }
  def console
    console ||= Object.new.extend(Console)
  end

  it "create_aliases doesn't save failed alias creation" do
    capture_stderr { console.create_aliases :blah, {} }
    Alias.manager.instance_eval("@created_aliases").should == {}
  end

  it "create_aliases takes partial creator names" do
    Alias.manager.expects(:create_aliases).with(:instance_method, {}, anything)
    console.create_aliases(:in, {})
  end

  it "search_aliases lists aliases if given nothing" do
    Alias.manager.expects(:all_aliases)
    console.search_aliases
  end

  describe "save_aliases" do
    before_all { eval "module ::Bluh; def blah; end; end" }
    before { Alias.manager.instance_eval("@created_aliases = nil") }

    it "saves created aliases" do
      hash = {"Bluh"=>{"blah"=>"bl"}}
      console.create_aliases :instance_method, hash
      File.expects(:exists?).returns(false)
      Alias.expects(:save_to_file).with("#{ENV['HOME']}/.alias.yml", {:aliases=>{:instance_method=>hash}}.to_yaml)
      capture_stdout { console.save_aliases }.should =~ /Save/
    end

    it "saves to given file" do
      hash = {"Bluh"=>{"blah"=>"b"}}
      console.create_aliases :instance_method, hash
      Alias.expects(:save_to_file).with("explicit", {:aliases=>{:instance_method=>hash}}.to_yaml)
      capture_stdout { console.save_aliases('explicit') }.should =~ /explicit/
    end

    it "prints message if nothing to save" do
      capture_stdout { console.save_aliases }.should =~ /Didn't save/
    end

    it "saves aliases to config/alias.yml if config/ exists" do
      File.expects(:directory?).returns(true)
      console.create_aliases :instance_method, {"Bluh"=>{"blah"=>"b2"}}
      Alias.expects(:save_to_file).with("config/alias.yml", anything)
      capture_stdout { console.save_aliases }
    end

    it "merges existing aliases with created aliases" do
      hash = {"Bluh"=>{"blah"=>"b3"}}
      console.create_aliases :instance_method, hash
      Alias.expects(:read_config_file).returns({:aliases=>{:instance_method=>{"Bluh"=>{"bling"=>"bl"}}}})
      Alias.expects(:save_to_file).with("#{ENV['HOME']}/.alias.yml",
        {:aliases=>{:instance_method=>{"Bluh"=>{'bling'=>'bl', 'blah'=>'b3'}}}}.to_yaml)
      capture_stdout { console.save_aliases }
    end
  end
end