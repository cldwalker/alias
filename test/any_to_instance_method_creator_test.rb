require File.join(File.dirname(__FILE__), 'test_helper.rb')

describe "AnyToInstanceMethodCreator" do
  before { @manager = Alias::Manager.new }

  def expect_aliases(hash)
    arr = Alias::Creators::AnyToInstanceMethodCreator.maps_config(hash)
    Alias::Creators::AnyToInstanceMethodCreator.expects(:generates_aliases).with(arr).returns('')
  end

  def create_aliases(hash)
    @manager.create_aliases(:any_to_instance_method, hash)
  end

  xtest "deletes invalid classes" do
    expect_aliases 'String'=>{'String.to_s'=>'s'}
    create_aliases 'String'=>{'String.to_s'=>'s'}, 'AnotherString'=>{'String.to_s'=>'s'}
  end

  xtest "deletes existing method aliases" do
    expect_aliases 'String'=>{'Date.commercial'=>'s'}
    create_aliases 'String'=>{'Date.civil'=>'strip', 'Date.commercial'=>'s'}
  end

  test "creates aliases" do
    Kernel.eval %[
      class ::SomeClass
        def self.cap; 'itup'; end
      end
      module ::SomeModule; end
    ]
    create_aliases 'SomeModule'=>{'SomeClass.cap.to_sym'=>'c', 'SomeClass.cap.gsub'=>'gsub'}
    obj = Object.new.extend SomeModule
    SomeClass.cap.to_sym.should == obj.c
    SomeClass.cap.gsub('cap','smack').should == obj.gsub('cap','smack')
  end
end