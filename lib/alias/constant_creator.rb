module Alias
  class ConstantCreator < Creator
    valid :alias, :unless=>:constant, :optional=>true
    valid :name, :if=>:constant
    map_config {|c| c.map {|k,v| {:name=>k, :alias=>v}} }

    create_aliases do |aliases|
      aliases.map {|e| "::#{e[:alias]} = ::#{e[:name]}"}.join("\n")
    end

    def generate_aliases(array_to_alias)
      Util.make_shortest_aliases(array_to_alias)
    end
  end
end
