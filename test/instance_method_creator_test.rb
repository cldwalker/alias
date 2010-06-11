require File.join(File.dirname(__FILE__), 'test_helper.rb')

describe "InstanceMethodCreator" do
  before { @manager = Manager.new }
  def expect_aliases(hash)
    arr = Creators::InstanceMethodCreator.maps_config(hash)
    Creators::InstanceMethodCreator.expects(:generates_aliases).with(arr).returns('')
  end

  def create_aliases(hash)
    @manager.create_aliases(:instance_method, hash)
  end
  
  it "deletes existing instance method aliases" do
    expect_aliases "String"=>{"strip"=>"st"}
    create_aliases 'String'=>{'strip'=>'st', 'chomp'=>'chop'}
  end

  it "deletes invalid classes" do
    expect_aliases "String"=>{'strip'=>'st'}
    create_aliases "String"=>{'strip'=>'st'}, 'Blah'=>{'map'=>'m'}
  end

  it "deletes invalid instance method keys" do
    expect_aliases "Array"=>{}, "String"=>{"strip"=>"st"}
    create_aliases 'String'=>{'strip'=>'st'},'Array'=>{'blah'=>'bl'}
  end

  it "creates aliases" do
    Kernel.eval %[
      class ::SampleClass
        def whoop; 'WHOOP'; end
      end
    ]
    obj = SampleClass.new
    create_aliases 'SampleClass'=>{:whoop=>:can_of_wass, :blah=>:bl}
    SampleClass.new.whoop.should == SampleClass.new.can_of_wass
  end
end