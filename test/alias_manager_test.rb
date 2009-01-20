require File.join(File.dirname(__FILE__), 'test_helper.rb')

class AliasManagerTest < Test::Unit::TestCase
    before(:each) { @manager = Alias::Manager.new}
    
    context "Manager" do
    test "verbosity trickles down to creator objects" do
      h1 = {'String'=>'Strang'}
      @manager.verbose = true
      @manager.create_aliases(:constant, h1)
      assert @manager.alias_creators[:constant].verbose
    end
    
    test "creates constant aliases" do
      h1 = {'Time'=>'T', 'auto_alias'=>['Date']}
      @manager.create_aliases(:constant, h1)
      @manager.constant_aliases.should == {'Time'=>'T', 'Date'=>'D'}
    end
    
    test "creates instance aliases" do
      Kernel.eval %[
        class ::SampleClass
          def whoop; 'WHOOP'; end
        end
      ]
      obj = SampleClass.new
      @manager.create_aliases(:instance, {'SampleClass'=>{:whoop=>:can_of_wass, :blah=>:bl}})
      @manager.instance_aliases.should == {'SampleClass'=>{:whoop=>:can_of_wass}}
      SampleClass.new.whoop.should == SampleClass.new.can_of_wass
    end
    
    test "creates klass aliases" do
      Kernel.eval %[
        class ::SampleClass
          def self.cap; 'itup'; end
        end
      ]
      hash1 = {'SampleClass'=>{:cap=>:capohow}, 'Array'=>{:blah=>:bl}}
      @manager.create_aliases(:klass, hash1)
      expected_result = {"SampleClass"=>{:cap=>:capohow}, "Array"=>{}}
      assert_equal expected_result, @manager.klass_aliases
      SampleClass.capohow.should == SampleClass.cap
    end
    end
  
end