require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::InstanceMethodCreatorTest < Test::Unit::TestCase
  context "InstanceMethodCreator" do
    before(:each) { @manager = Alias::Manager.new }
    def expect_aliases(hash)
      arr = Alias::InstanceMethodCreator.new.convert_map(hash)
      Alias::InstanceMethodCreator.any_instance.expects(:create_aliases).with(arr)
    end

    def create_aliases(hash)
      @manager.create_aliases(:instance_method, hash)
    end
    
    test "deletes existing instance method aliases" do
      expect_aliases "String"=>{"strip"=>"st"}
      create_aliases 'String'=>{'strip'=>'st', 'chomp'=>'chop'}
    end

    test "deletes invalid classes" do
      expect_aliases "String"=>{'strip','st'}
      create_aliases "String"=>{'strip','st'}, 'Blah'=>{'map'=>'m'}
    end

    test "deletes invalid instance method keys" do
      expect_aliases "Array"=>{}, "String"=>{"strip"=>"st"}
      create_aliases 'String'=>{'strip'=>'st'},'Array'=>{'blah', 'bl'}
    end

    test "creates aliases" do
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
end