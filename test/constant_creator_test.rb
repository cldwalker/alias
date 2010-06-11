require File.join(File.dirname(__FILE__), 'test_helper.rb')

describe "AliasConstantCreator" do
  before { @manager = Manager.new }

  def create_aliases(hash, options={})
    @manager.create_aliases(:constant, hash, options)
  end

  def expect_aliases(hash)
    arr = Creators::ConstantCreator.maps_config(hash)
    Creators::ConstantCreator.expects(:generates_aliases).with(arr).returns('')
  end
  
  it "deletes existing aliases" do
    expect_aliases "Array"=>'Ar'
    create_aliases "Alias::Creators::ConstantCreator"=>"Alias::Creator", "Array"=>"Ar"
  end

  it "deletes existing aliases unless force option" do
    h1 = {"Alias::Creators::ConstantCreator"=>"Alias::Creator", "Array"=>"Ar"}
    expect_aliases h1
    create_aliases h1, :force=>true
  end

  it "deletes invalid classes" do
    eval "module ::Bling; end"
    expect_aliases 'Array'=>'Ar'
    create_aliases "Blah"=>"Bling", "Array"=>"Ar"
  end

  it "creates aliases" do
    create_aliases 'Time'=>'T'
    ::Time.should == ::T
  end
end