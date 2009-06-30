require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::ConstantCreatorTest < Test::Unit::TestCase
  context "AliasConstantCreator" do
    before(:each) { @creator = Alias::ConstantCreator.new}

    def convert_map(hash)
      Alias::ConstantCreator.new.convert_map(hash)
    end
    
    test "deletes existing aliases" do
      @manager = Alias::Manager.new
      h1 = {"Alias::ConstantCreator"=>"Alias::Creator", "Array"=>"Ar"}
      Alias::ConstantCreator.any_instance.expects(:create_aliases).with(convert_map({"Array"=>"Ar"}))
      @manager.create_aliases(:constant, h1)
    end

    # TODO: alias
    # test "deletes existing alias unless it was created by the object" do
    #   h1 = {"Array"=>"A"}
    #   @creator.create(h1)
    #   assert_not_equal A, ArgumentError
    #   h2 = {"ArgumentError"=>"A"}
    #   @creator.create(h2)
    #   assert_equal A, ArgumentError
    # end
    
    test "to_searchable_array is an array of hashes" do
      @creator.alias_map = {'Alias'=>'A'}
      @creator.to_searchable_array.should == [{:name=>'Alias', :alias=>'A'}]
    end
  end
end