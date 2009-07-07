# Creates instance methods which can call any string of ruby code which ends in a method. This class provides the same 
# functionality that Alias::Creators::ClassToInstanceMethodCreator provides and more but at the cost of less validation.
# Expects a hash of classes/modules of the instance method mapped to a hash of ruby code strings and the instance method names.
# For example, the hash {"MyDate"=>{'Date.today.to_s.gsub'=>'t'}} creates a MyDate.t method which directly calls Date.today.to_s.gsub.
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