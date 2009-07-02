module Alias
  class ClassMethodCreator < Creator
    valid :class, :if=>:class
    valid :class_method, :if=>:class_method, :with=>[:class, :name]
    valid :alias, :unless=>:class_method, :with=>[:class, :alias], :optional=>true

    map_config do |c|
      c.inject([]) {|t,(klass,aliases)|
        t += aliases.map {|k,v| {:class=>klass, :name=>k, :alias=>v} }
      }
    end

    def create_aliases(aliases)
      eval_string = aliases.map {|e|
        klass = Util.any_const_get(e[:class])
        class_or_module = klass.is_a?(Class) ? 'class' : 'module'
        "#{class_or_module} ::#{e[:class]}; class<<self; alias_method :#{e[:alias]}, :#{e[:name]}; end; end"
      }.join("\n")
      eval(eval_string)
    end
  end
end