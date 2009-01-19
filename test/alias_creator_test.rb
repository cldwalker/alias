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
  
  
  context "Creator" do
    before(:each) { @creator = Alias::Manager.new}
    test "creates constant aliases" do
      h1 = {'Time'=>'T'}
      # @creator.create_constant_aliases(h1, :auto_alias=>['Date'])
      #td: auto_alias
      @creator.create_constant_aliases(h1)
      @creator.constant_aliases.should == {'Time'=>'T'}
    end
    
    test "creates instance aliases" do
      Kernel.eval %[
        class ::SampleClass
          def whoop; 'WHOOP'; end
        end
      ]
      obj = SampleClass.new
      @creator.create_instance_aliases({'SampleClass'=>{:whoop=>:can_of_wass}})
      SampleClass.new.whoop.should == SampleClass.new.can_of_wass
    end
    
    test "creates klass aliases" do
      Kernel.eval %[
        class ::SampleClass
          def self.cap; 'itup'; end
        end
      ]
      hash1 = {'SampleClass'=>{:cap=>:capohow}}
      @creator.create_klass_aliases(hash1).should == hash1
      SampleClass.capohow.should == SampleClass.cap
    end
  end
end