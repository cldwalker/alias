class Alias::Creators::AnyToInstanceMethodCreator < Alias::Creator
  map do |config|
    config.inject([]) {|t,(klass,hash)|
      t += hash.map {|k,v|
        {:class=>klass, :any_method=>k, :alias=>v}
      }
    }
  end

  valid :class, :if=>:class
  valid :alias, :unless=>:instance_method, :with=>[:class, :alias], :optional=>true

  generate do |aliases|
    aliases.map {|e|
      %[#{class_or_module(e[:class])} ::#{e[:class]}; def #{e[:alias]}(*args, &block); #{e[:any_method]}(*args, &block); end; end]
    }.join("\n")
  end
end