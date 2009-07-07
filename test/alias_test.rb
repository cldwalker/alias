require File.join(File.dirname(__FILE__), 'test_helper.rb')

class AliasTest < Test::Unit::TestCase
  context "Alias" do
    test "loads config file config/alias.yml if found" do
      File.expects(:exists?).with('config/alias.yml').returns(true)
      Alias.config_file.should == 'config/alias.yml'
    end

    context "create" do
      before(:each) { Alias.instance_eval "@manager = @config = @config_file = nil"}
    
      test "with aliases option creates aliases" do
        options = {:aliases=>{:constant=> {'Array'=>'Arr'}, :instance_method=>{'String'=>{'to_s'=>'s'}} } , :file=>false}
        Alias.create options
        Alias.manager.aliases_of(:instance_method).empty?.should be(false)
        Alias.manager.aliases_of(:constant).empty?.should be(false)
        Alias.config.should == options
      end
    
      test "with file option creates aliases" do
        Alias.create :file=>File.join(File.dirname(__FILE__),'aliases.yml')
        Alias.manager.aliases_of(:instance_method).empty?.should be(false)
        Alias.manager.aliases_of(:class_method).empty?.should be(false)
        Alias.manager.aliases_of(:constant).empty?.should be(false)
        Alias.manager.aliases_of(:class_to_instance_method).empty?.should be(false)
      end

      test "with false file option doesn't load config file" do
        Alias.create :file=>'blah'
        File.expects(:exists?).never
        Alias.create :file=>false
      end

      test "with invalid file option creates nothing" do
        Alias.create :file=>'blah'
        Alias.config.should == {:aliases=>{}}
      end
    
      test "with verbose option sets manager's verbose" do
        Alias.manager.verbose.should == false
        Alias.create :verbose=>true, :aliases=>{}, :file=>false
        Alias.manager.verbose.should == true
      end

      test "with force option sets manager's verbose" do
        Alias.manager.force.should == false
        Alias.create :force=>true, :aliases=>{}
        Alias.manager.force.should == true
      end

      test "called twice recursively merges config" do
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
end
