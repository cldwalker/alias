module Alias
  class InstanceMethodCreator < Creator
    map do |config|
      config.inject([]) {|t,(klass,aliases)|
        t += aliases.map {|k,v| {:class=>klass, :name=>k, :alias=>v} }
      }
    end

    valid :class, :if=>:class
    valid :instance_method, :if=>:instance_method, :with=>[:class, :name]
    valid :alias, :unless=>:instance_method, :with=>[:class, :alias], :optional=>true

    generate do |aliases|
      aliases.map {|e|
        "#{class_or_module(e[:class])} ::#{e[:class]}; alias_method :#{e[:alias]}, :#{e[:name]}; end"
      }.join("\n")
    end
  end
end