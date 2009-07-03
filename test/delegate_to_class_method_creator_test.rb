require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Alias::DelegateToMethodCreatorTest < Test::Unit::TestCase
  context "DelegateToClassMethodCreator" do
    before(:each) { @manager = Alias::Manager.new }

    def expect_aliases(hash)
      arr = Alias::DelegateToClassMethodCreator.maps_config(hash)
      Alias::DelegateToClassMethodCreator.expects(:creates_aliases).with(arr).returns('')
    end

    def create_aliases(hash)
      @manager.create_aliases(:delegate_to_class_method, hash)
    end

    test "deletes invalid delegate classes" do
      expect_aliases 'String'=>{'String.to_s'=>'s'}
      create_aliases 'String'=>{'AnotherString.name'=>'n', 'String.to_s'=>'s'}
    end

    test "deletes invalid classes" do
      expect_aliases 'String'=>{'String.to_s'=>'s'}
      create_aliases 'String'=>{'String.to_s'=>'s'}, 'AnotherString'=>{'String.to_s'=>'s'}
    end

    test "deletes existing method aliases" do
      expect_aliases 'String'=>{'Date.commercial'=>'s'}
      create_aliases 'String'=>{'Date.civil'=>'strip', 'Date.commercial'=>'s'}
    end

    test "deletes invalid delegate methods" do
      expect_aliases 'String'=>{'Date.civil'=>'c'}
      create_aliases 'String'=>{'Date.civil'=>'c', 'Date.uncivil'=>'uc'}
    end

    test "creates aliases" do
      Kernel.eval %[
        class ::SampleClass
          def self.cap; 'itup'; end
        end
        module ::SampleModule; end
      ]
      create_aliases 'SampleModule'=>{'SampleClass.cap'=>'c', 'Sampleclass.dap'=>'d'}
      obj = Object.new.extend SampleModule
      SampleClass.cap.should == obj.c
    end
  end
  
  test "to_searchable_array is an array of hashes" do
    @creator = Alias::DelegateToClassMethodCreator.new
    @creator.alias_map = {'String'=>{'AnotherString.name'=>'n'}}
    @creator.to_searchable_array.should == [{:delegate_name=>'name', :alias=>'n', :class=>'String', :delegate_class=>'AnotherString'}]
  end

end
