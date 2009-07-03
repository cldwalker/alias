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

    create_aliases do |aliases|
      aliases.map {|e|
        "#{class_or_module(e[:class])} ::#{e[:class]}; class<<self; alias_method :#{e[:alias]}, :#{e[:name]}; end; end"
      }.join("\n")
    end
  end
end