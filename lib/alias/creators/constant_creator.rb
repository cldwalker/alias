# Creates constants of aliases expecting a hash of existing constants mapped to their aliases.
class Alias::Creators::ConstantCreator < Alias::Creator
  map {|config| config.map {|k,v| {:name=>k, :alias=>v}} }

  valid :alias, :unless=>:constant, :optional=>true
  valid :name, :if=>:constant

  generate do |aliases|
    aliases.map {|e| "::#{e[:alias]} = ::#{e[:name]}"}.join("\n")
  end
end
