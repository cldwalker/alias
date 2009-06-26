module Alias
  class ConstantCreator < Creator
    
    def delete_invalid_aliases(aliases_hash)
      delete_invalid_class_keys(aliases_hash)
    end
    
    def delete_existing_aliases(aliases_hash)
      aliases_hash.each do |k, v| 
        if (klass = Util.any_const_get(v)) && ! alias_map.values.include?(v)
          aliases_hash.delete(k)
          puts "Alias '#{v}' deleted since the constant already exists" if self.verbose
        end
      end
    end
    
    def create_aliases(aliases_hash)
      eval_string = ''
      aliases_hash.each {|k,v|
        eval_string += "#{v} = #{k}\n"
      }
      Object.class_eval eval_string
    end
    
    def generate_aliases(array_to_alias)
      make_shortest_aliases(array_to_alias)
    end
    
    def to_searchable_array
      @alias_map.map {|k,v| {:name=>k, :alias=>v}}
    end
    
    def make_shortest_aliases(unaliased_strings)
      shortest_aliases = {}
      possible_alias = ''
      unaliased_strings.each {|s|
        possible_alias = ''
        s.split('').each { |e|
          possible_alias += e  
          if ! shortest_aliases.values.include?(possible_alias)
            shortest_aliases[s] = possible_alias
            break
          end
        }
      }

      shortest_aliases
    end
  end
end
