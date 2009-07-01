module Alias
  class DelegateToClassMethodCreator < Creator
    valid :class, :if=>:class
    valid :delegate_class, :if=>:class
    valid :aliased_method, :unless=>:instance_method, :with=>[:class, :alias]
    valid :delegate_method, :if=>:class_method, :with=>[:delegate_class, :delegate_name]

    def convert_map(aliases_hash)
      aliases_hash.inject([]) {|t,(klass,v)|
        t += v.map {|orig, aliased|
          {:class=>klass, :delegate_class=>orig.split('.')[0], :delegate_name=>orig.split('.')[1], :alias=>aliased}
        }
      }
    end

    def create_aliases(aliases)
      eval_string = aliases.map {|e|
        klass = any_const_get(e[:class])
        class_or_module = klass.is_a?(Class) ? 'class' : 'module'
        %[#{class_or_module} ::#{e[:class]}; def #{e[:alias]}(*args, &block); #{e[:delegate_class]}.__send__(:#{e[:delegate_name]}, *args, &block); end; end]
      }.join("\n")
      eval eval_string
    end
  end
end