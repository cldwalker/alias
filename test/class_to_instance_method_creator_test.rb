require File.join(File.dirname(__FILE__), 'test_helper.rb')

describe "ClassToInstanceMethodCreator" do
  before { @manager = Alias::Manager.new }

  def expect_aliases(hash)
    arr = Alias::Creators::ClassToInstanceMethodCreator.maps_config(hash)
    Alias::Creators::ClassToInstanceMethodCreator.expects(:generates_aliases).with(arr).returns('')
  end

  def create_aliases(hash)
    @manager.create_aliases(:class_to_instance_method, hash)
  end

  test "deletes invalid to classes" do
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

  test "deletes invalid to methods" do
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