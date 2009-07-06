require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::ManagerTest < Test::Unit::TestCase
    before(:each) { @manager = Alias::Manager.new}

    context "create_aliases" do
      before(:all) { eval %[class Alias::ValidTestCreator < Alias::Creator; map { [] }; generate { ' '};  end]}
      def create_aliases(options={})
        @manager.create_aliases :valid_test, {}, options
      end

      test "creates aliases" do
        Kernel.expects(:eval).with(' ')
        create_aliases
      end

      test "doesn't create aliases with pretend option" do
        Kernel.expects(:eval).never
        capture_stdout { create_aliases :pretend=>true }.should == " \n"
      end

      test "with manager's verbose sets creator's verbose" do
        @manager.verbose = true
        create_aliases
        @manager.creators[:valid_test].verbose.should == true
      end

      test "with manager's verbose array sets creator's verbose" do
        @manager.verbose = [:valid_test]
        create_aliases
        @manager.creators[:valid_test].verbose.should == true
      end

      test "with manager's verbose array doesn't set creator's verbose" do
        @manager.verbose = [:another]
        create_aliases
        @manager.creators[:valid_test].verbose.should == false
      end

      test "with manager's force sets creator's force" do
        @manager.force = true
        create_aliases
        @manager.creators[:valid_test].force.should == true
      end

      test "with manager's force array sets creator's force" do
        @manager.force = [:valid_test]
        create_aliases
        @manager.creators[:valid_test].force.should == true
      end

      test "with manager's force array doesn't set creators force" do
        @manager.force = [:another]
        create_aliases
        @manager.creators[:valid_test].force.should == false
      end

      test "force option sets force in creator object" do
        create_aliases :force=>true
        @manager.creators[:valid_test].force.should == true
      end

      test "verbose option sets verbose in creator object" do
        create_aliases :verbose=>true
        @manager.creators[:valid_test].verbose.should == true
      end

      test "prints error if nonexistent creator given" do
        capture_stderr {@manager.create_aliases :blah, {} }.should =~ /not found/
      end

      test "prints error if necessary creator methods not defined" do
        eval "class Alias::BlingCreator < Alias::Creator; end"
        capture_stderr { @manager.create_aliases :bling, {} }.should =~ /BlingCreator/
      end

      test "prints error if aliases fail to create" do
        eval "class Alias::Bling2Creator < Alias::Creator; map {[]}; generate { 'blah' }; end"
        capture_stderr { @manager.create_aliases :bling2, {} }.should =~ /failed to create aliases/
      end
    end

    context "search" do
      def setup_search
        @manager.creators = {:constant=>Alias::ConstantCreator.new}
        @manager.expects(:all_aliases).returns([{:name=>'Array', :alias=>'A'}, {:name=>'Abbrev', :alias=>'Ab'}])
      end

      test "with string returns exact match" do
        setup_search
        @manager.search(:name=>'Array').should == [{:name=>'Array', :alias=>'A'}]
      end
      
      test "with regex returns multiple matches " do
        setup_search
        @manager.search(:name=>/A/).should == [{:name=>'Array', :alias=>'A'}, {:name=>'Abbrev', :alias=>'Ab'}]
      end
    end
end
