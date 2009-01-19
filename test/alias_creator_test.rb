require File.join(File.dirname(__FILE__), 'test_helper.rb')

class AliasCreatorTest < Test::Unit::TestCase
  context "Make shortest aliases" do
    before(:all) { eval "::Y = 'some value'" }
    before(:each) { @creator = Alias::ConstantCreator.new}
    
    test "without constant checks" do
      expected_hash = {"Yo"=>"Y", "Man"=>"M", "Cool"=>"C", 'Yay'=>'Ya'}
      @creator.make_shortest_aliases(['Yo','Yay','Cool','Man'], :constant=>false).should == expected_hash
    end
   
    test "with constant checks" do
      expected_hash = {"Yo"=>"Yo", "Man"=>"M", "Cool"=>"C", 'Yay'=>'Ya'}
      @creator.make_shortest_aliases(['Yo','Yay','Cool','Man'], :constant=>true).should == expected_hash
    end
  end
  
  test "Creator cleans invalid klass keys" do
    h1 = {'Alias::Creator'=>'whoop','Yay'=>'Haha'}
    @creator = Alias::Creator.new
    @creator.clean_invalid_klass_keys(h1)
    h1.should == {'Alias::Creator'=>'whoop'}
  end
    
end