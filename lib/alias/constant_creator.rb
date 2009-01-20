module Alias
  class ConstantCreator < Creator
    
    def validate_aliases(aliases_hash)
      clean_invalid_klass_keys(aliases_hash)
    end
    
    def create_aliases(aliases_hash)
      eval_string = ''
      aliases_hash.each {|k,v|
        eval_string += "#{v} = #{k}\n"
      }
      Object.class_eval eval_string
    end
    
    def generate_aliases(array_to_alias)
      make_shortest_aliases(array_to_alias, :constant=>true)
    end
    
    def make_shortest_aliases(unaliased_strings,options={})
      options = {:constant=>false}.update(options)
      shortest_aliases = {}
      possible_alias = ''
      unaliased_strings.each {|s|
        possible_alias = ''
        s.split('').each { |e|
          possible_alias += e  
          if ! shortest_aliases.values.include?(possible_alias) && ! (options[:constant] && Object.const_defined?(possible_alias))
            shortest_aliases[s] = possible_alias
            break
          end
        }
      }

      shortest_aliases
    end
  end
end
