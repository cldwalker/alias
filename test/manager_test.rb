require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::ManagerTest < Test::Unit::TestCase
    before(:each) { @manager = Alias::Manager.new}
    
    context "Manager" do
      test "verbosity trickles down to creator objects" do
        h1 = {'String'=>'Strang'}
        @manager.verbose = true
        @manager.create_aliases(:constant, h1)
        assert @manager.alias_creators[:constant].verbose
      end
    
      test "force option sets force in creator object" do
        h1 = {'force'=>true}
        @manager.create_aliases(:constant, h1)
        assert @manager.alias_creators[:constant].force
      end
    
      context "search" do
        def setup_search
          @manager.alias_creators = {:constant=>Alias::ConstantCreator.new}
          @manager.expects(:indexed_aliases).returns([{:name=>'Array', :alias=>'A'}, {:name=>'Abbrev', :alias=>'Ab'}])
        end
        
        test "sets creator's searched_at" do
          setup_search
          assert @manager.alias_creators[:constant].searched_at.nil? 
          @manager.search :name=>'blah'
          assert @manager.alias_creators[:constant].searched_at.is_a?(Time)
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
      
      context "when indexing search" do
        def setup_index
          @creator = Alias::ConstantCreator.new
          @creator.alias_map = {'Array'=>'A', 'Abbrev'=>'Ab'}
          @manager.alias_creators = {:constant=>@creator}
        end
        
        test "works when first initialized" do
          setup_index
          @creator.stubs(:modified_since_last_search?).returns(true)
          expected_result = [{:type=>"constant", :name=>"Array", :alias=>"A"}, {:type=>"constant", :name=>"Abbrev", :alias=>"Ab"}]
          assert @manager.indexed_aliases(false).nil?
          @manager.indexed_aliases.should == expected_result
        end
        
        test "with modified creator, deletes old + adds new aliases" do
          original_aliases = [{:type=>"constant", :name=>"Enumerable", :alias=>"E"}]
          @manager.indexed_aliases = original_aliases
          setup_index
          @creator.stubs(:modified_since_last_search?).returns(true)
          expected_result = [{:type=>"constant", :name=>"Array", :alias=>"A"}, {:type=>"constant", :name=>"Abbrev", :alias=>"Ab"}]
          assert @manager.indexed_aliases(false).include?(original_aliases[0])
          @manager.indexed_aliases.should == expected_result
          assert !@manager.indexed_aliases.include?(original_aliases[0])
        end
        
        test "with unmodified creator, doesn't change any aliases" do
          setup_index
          @manager.indexed_aliases = [{:type=>"constant", :name=>"Enumerable", :alias=>"E"}]
          @creator.stubs(:modified_since_last_search?).returns(false)
          @manager.indexed_aliases.should ==  [{:type=>"constant", :name=>"Enumerable", :alias=>"E"}]
        end
      end
    end
    
end
