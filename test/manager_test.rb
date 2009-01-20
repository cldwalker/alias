require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::ManagerTest < Test::Unit::TestCase
    before(:each) { @manager = Alias::Manager.new}
    
    context "Manager" do
    test "verbosity trickles down to creator objects" do
      h1 = {'String'=>'Strang'}
      @manager.verbose = true
      @manager.create_aliases(:constant, h1)
      assert @manager.alias_creators[:constant].verbose
    end
    
    test "force option sets force in creator object" do
      h1 = {'force'=>true}
      @manager.create_aliases(:constant, h1)
      assert @manager.alias_creators[:constant].force
    end
    
    test "creates constant aliases" do
      h1 = {'Time'=>'T', 'auto_alias'=>['Date']}
      @manager.create_aliases(:constant, h1)
      @manager.constant_aliases.should == {'Time'=>'T', 'Date'=>'D'}
    end
    
    test "creates instance method aliases" do
      Kernel.eval %[
        class ::SampleClass
          def whoop; 'WHOOP'; end
        end
      ]
      obj = SampleClass.new
      @manager.create_aliases(:instance_method, {'SampleClass'=>{:whoop=>:can_of_wass, :blah=>:bl}})
      @manager.instance_method_aliases.should == {'SampleClass'=>{:whoop=>:can_of_wass}}
      SampleClass.new.whoop.should == SampleClass.new.can_of_wass
    end
    
    test "creates class method aliases" do
      Kernel.eval %[
        class ::SampleClass
          def self.cap; 'itup'; end
        end
      ]
      hash1 = {'SampleClass'=>{:cap=>:capohow}, 'Array'=>{:blah=>:bl}}
      @manager.create_aliases(:class_method, hash1)
      expected_result = {"SampleClass"=>{:cap=>:capohow}, "Array"=>{}}
      assert_equal expected_result, @manager.class_method_aliases
      SampleClass.capohow.should == SampleClass.cap
    end
    end
  
end
