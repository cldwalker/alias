require 'g/forwardable'
require 'test_helper'

#used by all
eval %[
  class SampleClass
    def self.cap; 'itup'; end
  end
]

context "main" do
  specify "import_methods" do
    eval "class NewClass; end"
    import_method_to_class(:cap,'SampleClass',NewClass)
    SampleClass.cap.should == NewClass.new.cap
  end
  
  specify "import_klass_methods" do
      o1 = stub('rover',:power=>'sonic bark')
      import_methods_to_object(o1,'SampleClass'=>'cap', 'Time'=>'now')
      o1.cap.should == 'itup'
      o1.now.is_a?(Time).should be_true
  end
  
  #also testing hash form of export()
  specify "import_no_validate" do
    o1 = stub('rover',:power=>'sonic bark')
    h1 = {'Time'=>{:whoop=>:w,:now=>:now}}
    import_methods_to_object(o1, h1, :validate=>false)
    h1.should == h1
    o1.now.is_a?(Time).should be_true
  end
  
  specify "import_validate" do
    o1 = stub('rover',:power=>'sonic bark')
    h1 = {'Time'=>{:whoop=>:w,:now=>:n}}
    import_methods_to_object(o1, h1, :validate=>true)
    h1.should == {'Time'=>{:now=>:n}}
  end
  
  specify "export_invalid_klass" do
    o1 = mock('fake_object')
    o1.should_not_receive(:def_delegators)
    export(o1,'InvalidKlass','somemethod')
  end
end

context "aliases" do
  specify "valid_klass_aliases" do
    hash1 = {'SampleClass'=>{:cap=>:capohow}}
    create_aliases(hash1, :klass_alias=>true).should == hash1
    SampleClass.capohow.should == SampleClass.cap
  end
  
  specify "nonextistent_klass" do
    create_aliases({'VoidClass'=>{:yes=>:yay}}, :klass_alias=>true)
    Object.const_defined?('VoidClass').should be_false
  end
  
  specify "nonexistent_methods" do
    create_aliases({'SampleClass'=>{:void_method=>:vm}}, :klass_alias=>true)
    SampleClass.respond_to?(:void_method).should be_false
    SampleClass.respond_to?(:vm).should be_false
  end
  
  specify "instance_aliases" do
    eval %[
      class SampleClass
        def whoop; 'WHOOP'; end
      end
    ]
    create_aliases({'SampleClass'=>{:whoop=>:can_of_wass}})
    SampleClass.new.whoop.should == SampleClass.new.can_of_wass
  end
end