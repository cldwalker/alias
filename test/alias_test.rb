require File.join(File.dirname(__FILE__), 'test_helper.rb')

describe "Alias" do
  it "loads config file config/alias.yml if found" do
    File.expects(:exists?).with('config/alias.yml').returns(true)
    Alias.config_file.should == 'config/alias.yml'
  end

  describe "create" do
    before { Alias.instance_eval "@manager = @config = @config_file = nil"}
  
    it "with aliases option creates aliases" do
      options = {:aliases=>{:constant=> {'Array'=>'Arr'}, :instance_method=>{'String'=>{'to_s'=>'s'}} } , :file=>false}
      Alias.create options
      Alias.manager.aliases_of(:instance_method).empty?.should == false
      Alias.manager.aliases_of(:constant).empty?.should == false
      Alias.config.should == options
    end
  
    it "with file option creates aliases" do
      Alias.create :file=>File.join(File.dirname(__FILE__),'aliases.yml')
      Alias.manager.aliases_of(:instance_method).empty?.should == false
      Alias.manager.aliases_of(:class_method).empty?.should == false
      Alias.manager.aliases_of(:constant).empty?.should == false
      Alias.manager.aliases_of(:class_to_instance_method).empty?.should == false
    end

    it "with false file option doesn't load config file" do
      Alias.create :file=>'blah'
      File.expects(:exists?).never
      Alias.create :file=>false
    end

    it "with invalid file option creates nothing" do
      Alias.create :file=>'blah'
      Alias.config.should == {:aliases=>{}}
    end
  
    it "with verbose option sets manager's verbose" do
      Alias.manager.verbose.should == false
      Alias.create :verbose=>true, :aliases=>{}, :file=>false
      Alias.manager.verbose.should == true
    end

    it "with force option sets manager's verbose" do
      Alias.manager.force.should == false
      Alias.create :force=>true, :aliases=>{}
      Alias.manager.force.should == true
    end

    it "called twice recursively merges config" do
      hash1 = {:constant=>{"Blah"=>"B"}}
      Alias.manager.expects(:create_aliases).with(:constant, hash1[:constant])
      Alias.create :aliases=>hash1, :file=>false
      hash2 = {:constant=>{"Blah2"=>"B2"}}
      Alias.manager.expects(:create_aliases).with(:constant, hash2[:constant])
      Alias.create :aliases=>hash2, :file=>false
      Alias.config.should == {:aliases=>{:constant=>{"Blah"=>"B", "Blah2"=>"B2"}} }
    end
  end
end