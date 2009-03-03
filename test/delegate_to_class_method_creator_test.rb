require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::DelegateToMethodCreatorTest < Test::Unit::TestCase
  before(:each) { @creator = Alias::DelegateToClassMethodCreator.new }
  
  test "deletes invalid delegate classes" do
    h1 = {'String'=>[['n', 'AnotherString', 'name'], ['s', 'String', 'to_s']]}
    @creator.delete_invalid_delegate_classes(h1)
    h1.should == {"String"=>[["s", "String", "to_s"]]}
  end
  
  test "deletes invalid delegate methods" do
    h1 = {'QuickDate'=>[['c', 'Date', 'civil'], ['uc', 'Date', 'uncivil']]}
    @creator.delete_invalid_delegate_methods(h1)
    h1.should == {"QuickDate"=>[["c", "Date", "civil"]]}
  end
  
  test "deletes existing method aliases" do
    h1 = {'String'=>[['strip', 'Date', 'civil'], ['s', 'Date', 'civil']]}
    @creator.delete_existing_aliases(h1)
    h1.should == {"String"=>[["s", "Date", "civil"]]}
  end
  
  test "to_searchable_array is an array of hashes" do
    @creator.alias_map = {'String'=>[['n', 'AnotherString', 'name']]}
    @creator.to_searchable_array.should == [{:delegate_name=>'name', :alias=>'n', :class=>'String', :delegate_class=>'AnotherString'}]
  end

end
