require File.join(File.dirname(__FILE__), 'test_helper.rb')

describe "Manager" do
  before { @manager = nil }
  def manager; @manager ||= Alias::Manager.new; end

  describe "create_aliases" do
    before_all { eval %[class Alias::Creators::ValidTestCreator < Alias::Creator; map { [] }; generate { ' '};  end]}
    def create_aliases(options={})
      manager.create_aliases :valid_test, {}, options
    end

    test "creates aliases" do
      Kernel.expects(:eval).with(' ')
      create_aliases
    end

    test "doesn't create aliases with pretend option" do
      Kernel.expects(:eval).never
      capture_stdout { create_aliases :pretend=>true }.should == "\n \n"
    end

    test "with manager's verbose sets creator's verbose" do
      manager.verbose = true
      create_aliases
      manager.creators[:valid_test].verbose.should == true
    end

    test "with manager's verbose array sets creator's verbose" do
      manager.verbose = [:valid_test]
      create_aliases
      manager.creators[:valid_test].verbose.should == true
    end

    test "with manager's verbose array doesn't set creator's verbose" do
      manager.verbose = [:another]
      create_aliases
      manager.creators[:valid_test].verbose.should == false
    end

    test "with manager's force sets creator's force" do
      manager.force = true
      create_aliases
      manager.creators[:valid_test].force.should == true
    end

    test "with manager's force array sets creator's force" do
      manager.force = [:valid_test]
      create_aliases
      manager.creators[:valid_test].force.should == true
    end

    test "with manager's force array doesn't set creators force" do
      manager.force = [:another]
      create_aliases
      manager.creators[:valid_test].force.should == false
    end

    test "force option sets force in creator object" do
      create_aliases :force=>true
      manager.creators[:valid_test].force.should == true
    end

    test "verbose option sets verbose in creator object" do
      create_aliases :verbose=>true
      manager.creators[:valid_test].verbose.should == true
    end

    test "prints error if nonexistent creator given" do
      capture_stderr {manager.create_aliases :blah, {} }.should =~ /not found/
    end

    test "prints error if necessary creator methods not defined" do
      eval "class Alias::Creators::BlingCreator < Alias::Creator; end"
      capture_stderr { manager.create_aliases :bling, {} }.should =~ /BlingCreator/
    end

    test "prints error if aliases fail to create" do
      eval "class Alias::Creators::Bling2Creator < Alias::Creator; map {[]}; generate { 'blah' }; end"
      capture_stderr { manager.create_aliases :bling2, {} }.should =~ /failed to create aliases/
    end
  end

  describe "search" do
    before {
      manager.instance_variable_set "@creators", {:constant=>Alias::Creators::ConstantCreator.new}
      manager.stubs(:all_aliases).returns([{:name=>'Array', :alias=>'A'}, {:name=>'Abbrev', :alias=>'B'}])
    }

    test "key and symbol value" do
      manager.search(:name=>:Array).should == [{:name=>'Array', :alias=>'A'}]
    end
    
    test "with key and string value" do
      manager.search(:name=>'A').should == [{:name=>'Array', :alias=>'A'}, {:name=>'Abbrev', :alias=>'B'}]
    end

    test "with a string" do
      manager.search('Array').should == [{:name=>'Array', :alias=>'A'}]
    end

    test "with multiple search terms" do
      manager.search(:name=>'A', :alias=>'A').should == [{:name=>'Array', :alias=>'A'}]
    end
  end
end
