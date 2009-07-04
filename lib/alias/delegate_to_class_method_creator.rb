module Alias
  class DelegateToClassMethodCreator < Creator
    map do |config|
      config.inject([]) {|t,(klass,v)|
        t += v.map {|orig, aliased|
          {:class=>klass, :delegate_class=>orig.split('.')[0], :delegate_name=>orig.split('.')[1], :alias=>aliased}
        }
      }
    end

    valid :class, :if=>:class
    valid :delegate_class, :if=>:class
    valid :alias, :unless=>:instance_method, :with=>[:class, :alias], :optional=>true
    valid :delegate_method, :if=>:class_method, :with=>[:delegate_class, :delegate_name]

    generate do |aliases|
      aliases.map {|e|
        %[#{class_or_module(e[:class])} ::#{e[:class]}; def #{e[:alias]}(*args, &block); #{e[:delegate_class]}.__send__(:#{e[:delegate_name]}, *args, &block); end; end]
      }.join("\n")
    end
  end
end