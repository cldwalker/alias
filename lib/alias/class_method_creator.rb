module Alias
  class ClassMethodCreator < Creator
    map do |config|
      config.inject([]) {|t,(klass,aliases)|
        t += aliases.map {|k,v| {:class=>klass, :name=>k, :alias=>v} }
      }
    end

    valid :class, :if=>:class
    valid :class_method, :if=>:class_method, :with=>[:class, :name]
    valid :alias, :unless=>:class_method, :with=>[:class, :alias], :optional=>true

    generate do |aliases|
      aliases.map {|e|
        "#{class_or_module(e[:class])} ::#{e[:class]}; class<<self; alias_method :#{e[:alias]}, :#{e[:name]}; end; end"
      }.join("\n")
    end
  end
end