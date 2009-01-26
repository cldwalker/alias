require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::ConstantCreatorTest < Test::Unit::TestCase
  context "AliasConstantCreator" do
    before(:each) { @creator = Alias::ConstantCreator.new}
    
    test "deletes existing aliases" do
      h1 = {"Alias::ConstantCreator"=>"Alias::Creator", "Array"=>"Ar"}
      @creator.delete_existing_aliases(h1)
      h1.should == {"Array"=>"Ar"}
    end
    
    test "deletes existing alias unless it was created by the object" do
      h1 = {"Array"=>"A"}
      @creator.create(h1)
      assert_not_equal A, ArgumentError
      h2 = {"ArgumentError"=>"A"}
      @creator.create(h2)
      assert_equal A, ArgumentError
    end
    
    test "makes shortest aliases" do
      eval "::Y = 'some value'"
      expected_hash = {"Yo"=>"Y", "Man"=>"M", "Cool"=>"C", 'Yay'=>'Ya'}
      @creator.make_shortest_aliases(['Yo','Yay','Cool','Man']).should == expected_hash
    end
    
    test "to_searchable_array is an array of hashes" do
      @creator.alias_map = {'Alias'=>'A'}
      @creator.to_searchable_array.should == [{:name=>'Alias', :alias=>'A'}]
    end
  end
end