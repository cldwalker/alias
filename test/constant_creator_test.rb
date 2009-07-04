require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::ConstantCreatorTest < Test::Unit::TestCase
  context "AliasConstantCreator" do
    before(:each) { @manager = Alias::Manager.new }

    def create_aliases(hash, options={})
      @manager.create_aliases(:constant, hash, options)
    end

    def expect_aliases(hash)
      arr = Alias::ConstantCreator.maps_config(hash)
      Alias::ConstantCreator.expects(:generates_aliases).with(arr).returns('')
    end
    
    test "deletes existing aliases" do
      expect_aliases "Array"=>'Ar'
      create_aliases "Alias::ConstantCreator"=>"Alias::Creator", "Array"=>"Ar"
    end

    test "deletes existing aliases unless force option" do
      h1 = {"Alias::ConstantCreator"=>"Alias::Creator", "Array"=>"Ar"}
      expect_aliases h1
      create_aliases h1, :force=>true
    end

    test "deletes invalid classes" do
      eval "module ::Bling; end"
      expect_aliases 'Array'=>'Ar'
      create_aliases "Blah"=>"Bling", "Array"=>"Ar"
    end

    test "creates aliases" do
      create_aliases 'Time'=>'T'
      ::Time.should == ::T
    end
  end
end