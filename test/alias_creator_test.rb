require File.join(File.dirname(__FILE__), 'test_helper.rb')

class AliasCreatorTest < Test::Unit::TestCase
  # describe "shortest_nonconstant_aliases" do
  #   expected_hash = {"Yo"=>"Y", "Man"=>"M", "Cool"=>"C", 'Yay'=>'Ya'}
  #   eval "::Y = 'some value'"
  #   AliasCreatorI.make_shortest_aliases(['Yo','Yay','Cool','Man'], :constant=>false).should ==
  #     expected_hash
  # end
  # 
  # describe "shortest_constant_aliases" do
  #   expected_hash = {"Yo"=>"Yo", "Man"=>"M", "Cool"=>"C", 'Yay'=>'Ya'}
  #   eval "::Y = 'some value'"
  #   AliasCreatorI.make_shortest_aliases(['Yo','Yay','Cool','Man'], :constant=>true).should ==
  #     expected_hash
  # end
  #
  context "Creator" do
    before(:each) { @creator = Alias::Creator.new}
    test "create_constant_aliases" do
      h1 = {'Time'=>'T'}
      @creator.create_constant_aliases(h1, :auto_alias=>['Date'])
      @creator.constant_aliases.should == {'Time'=>'T','Date'=>'D'}
    end
    
    test "clean_invalid_klass_keys" do
      h1 = {'Alias::Creator'=>'whoop','Yay'=>'Haha'}
      @creator.clean_invalid_klass_keys(h1)
      h1.should == {'Alias::Creator'=>'whoop'}
    end
    
    test "create_instance_aliases" do
      Kernel.eval %[
        class ::SampleClass
          def whoop; 'WHOOP'; end
        end
      ]
      obj = SampleClass.new
      @creator.create_instance_aliases({'SampleClass'=>{:whoop=>:can_of_wass}})
      SampleClass.new.whoop.should == SampleClass.new.can_of_wass
    end
    
    test "create_klass_aliases" do
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