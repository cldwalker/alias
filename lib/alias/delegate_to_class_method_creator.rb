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

    def create_aliases(aliases)
      eval_string = aliases.map {|e|
        klass = Util.any_const_get(e[:class])
        class_or_module = klass.is_a?(Class) ? 'class' : 'module'
        %[#{class_or_module} ::#{e[:class]}; def #{e[:alias]}(*args, &block); #{e[:delegate_class]}.__send__(:#{e[:delegate_name]}, *args, &block); end; end]
      }.join("\n")
      eval eval_string
    end
  end
end