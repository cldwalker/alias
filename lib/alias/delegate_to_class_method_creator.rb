module Alias
  class DelegateToClassMethodCreator < Creator
    valid :class, :if=>:class
    valid :delegate_class, :if=>:class
    valid :alias, :unless=>:instance_method, :with=>[:class, :alias], :optional=>true
    valid :delegate_method, :if=>:class_method, :with=>[:delegate_class, :delegate_name]

    map_config do |c|
      c.inject([]) {|t,(klass,v)|
        t += v.map {|orig, aliased|
          {:class=>klass, :delegate_class=>orig.split('.')[0], :delegate_name=>orig.split('.')[1], :alias=>aliased}
        }
      }
    end

    create_aliases do |aliases|
      aliases.map {|e|
        %[#{class_or_module(e[:class])} ::#{e[:class]}; def #{e[:alias]}(*args, &block); #{e[:delegate_class]}.__send__(:#{e[:delegate_name]}, *args, &block); end; end]
      }.join("\n")
    end
  end
end