module Alias
  class ConstantCreator < Creator
    valid :alias, :unless=>:constant
    valid :name, :if=>:constant

    def create_aliases(arr)
      eval_string = arr.map {|e| "#{e[:alias]} = #{e[:name]}"}.join("\n")
      Object.class_eval eval_string
    end

    def convert_map(aliases_hash)
      aliases_hash.map {|k,v| {:name=>k, :alias=>v}}
    end

    def generate_aliases(array_to_alias)
      Util.make_shortest_aliases(array_to_alias)
    end
  end
end
