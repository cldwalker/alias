module Alias
  class InstanceMethodCreator < Creator
    valid :class, :if=>:class
    valid :instance_method, :if=> lambda {|e| instance_method?(e[:class], e[:name]) }
    valid :aliased_method, :unless=>lambda {|e| instance_method?(e[:class], e[:alias]) }

    def convert_map(hash)
      hash.inject([]) {|t,(klass,aliases)|
        t += aliases.map {|k,v| {:class=>klass, :name=>k, :alias=>v} }
      }
    end

    def create_aliases(aliases)
      eval_string = aliases.map {|e|
        klass = any_const_get(e[:class])
        class_or_module = klass.is_a?(Class) ? 'class' : 'module'
        "#{class_or_module} ::#{e[:class]}; alias_method :#{e[:alias]}, :#{e[:name]}; end"
      }.join("\n")
      eval(eval_string)
    end
  end
end