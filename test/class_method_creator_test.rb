require File.join(File.dirname(__FILE__), 'test_helper.rb')

describe "ClassMethodCreator" do
  before { @manager = Alias::Manager.new }
  def expect_aliases(hash)
    arr = Alias::Creators::ClassMethodCreator.maps_config(hash)
    Alias::Creators::ClassMethodCreator.expects(:generates_aliases).with(arr).returns('')
  end

  def create_aliases(hash)
    @manager.create_aliases(:class_method, hash)
  end
  
  test "deletes invalid class method keys" do
    expect_aliases "Array"=>{}, "String"=>{'yaml_new'=>'yn'}
    create_aliases 'String'=>{'yaml_new'=>'yn'},'Array'=>{'blah'=>'bl'}
  end

  test "deletes invalid classes" do
    expect_aliases "String"=>{'yaml_new'=>'yn'}
    create_aliases 'String'=>{'yaml_new'=>'yn'},'Blah'=>{'new'=>'n'}
  end

  test "deletes existing class method aliases" do
    expect_aliases 'Date'=>{'valid_time?'=>'vt'}
    create_aliases 'Date'=>{'civil_to_jd'=>'civil', 'valid_time?'=>'vt'}
  end

  test "creates class method aliases" do
    Kernel.eval %[
      class ::SampleClass
        def self.cap; 'itup'; end
      end
    ]
    hash1 = {'SampleClass'=>{:cap=>:capohow}, 'Array'=>{:blah=>:bl}}
    @manager.create_aliases(:class_method, hash1)
    SampleClass.capohow.should == SampleClass.cap
  end
end