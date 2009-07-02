require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::ConstantCreatorTest < Test::Unit::TestCase
  context "AliasConstantCreator" do
    before(:each) { @manager = Alias::Manager.new }

    def create_aliases(hash)
      @manager.create_aliases(:constant, hash)
    end

    def expect_aliases(hash)
      arr = Alias::ConstantCreator.new.convert_map(hash)
      Alias::ConstantCreator.any_instance.expects(:create_aliases).with(arr)
    end
    
    test "deletes existing aliases" do
      expect_aliases "Array"=>'Ar'
      create_aliases "Alias::ConstantCreator"=>"Alias::Creator", "Array"=>"Ar"
    end

    test "deletes existing aliases unless force option" do
      h1 = {"Alias::ConstantCreator"=>"Alias::Creator", "Array"=>"Ar"}
      expect_aliases h1
      create_aliases h1.merge('force'=>true)
    end

    test "deletes invalid classes" do
      eval "module ::Bling; end"
      expect_aliases 'Array'=>'Ar'
      create_aliases "Blah"=>"Bling", "Array"=>"Ar"
    end

    test "creates aliases" do
      create_aliases 'Time'=>'T', 'auto_alias'=>['Date']
      ::Time.should == ::T
      ::D.should == ::D
    end
  end

  test "to_searchable_array is an array of hashes" do
    @creator = Alias::ConstantCreator.new
    @creator.alias_map = {'Alias'=>'A'}
    @creator.to_searchable_array.should == [{:name=>'Alias', :alias=>'A'}]
  end
end