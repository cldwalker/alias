module Alias
  class ConstantCreator < Creator
    delete_existing :alias, :if=>:constant, :message=>"Alias '%s' deleted since the constant already exists"

    def delete_invalid_aliases(aliases_hash)
      delete_invalid_class_keys(aliases_hash)
    end
    
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

    def to_searchable_array
      convert_map(@alias_map)
    end
  end
end
