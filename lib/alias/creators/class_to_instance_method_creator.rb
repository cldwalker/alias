class Alias::Creators::ClassToInstanceMethodCreator < Alias::Creator
  map do |config|
    config.inject([]) {|t,(klass,hash)|
      t += hash.map {|k,v|
        {:class=>klass, :to_class=>k.split('.')[0], :name=>k.split('.')[1], :alias=>v}
      }
    }
  end

  valid :class, :if=>:class
  valid :to_class, :if=>:class
  valid :alias, :unless=>:instance_method, :with=>[:class, :alias], :optional=>true
  valid :to_method, :if=>:class_method, :with=>[:to_class, :name]

  generate do |aliases|
    aliases.map {|e|
      %[#{class_or_module(e[:class])} ::#{e[:class]}; def #{e[:alias]}(*args, &block); #{e[:to_class]}.__send__(:#{e[:name]}, *args, &block); end; end]
    }.join("\n")
  end
end