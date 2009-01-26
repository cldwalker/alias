module Alias
  module MethodCreatorHelper
    def delete_invalid_aliases(aliases_hash)
      delete_invalid_class_keys(aliases_hash)
      delete_invalid_method_keys(aliases_hash)
    end
    
    def delete_existing_aliases(aliases_hash)
      delete_existing_method_aliases(aliases_hash)
    end
    
    def create_aliases(aliases_hash)
      create_method_aliases(aliases_hash)
    end
    
    def method_exists?(klass, method)
      raise "This abstract method must be overridden."
    end
    
    def delete_invalid_method_keys(alias_hash)
      alias_hash.each do |k, methods|
        if klass = Object.any_const_get(k)
          methods.keys.each do |e|
            if ! method_exists?(klass,e)
              methods.delete(e)
              puts "#{klass}: alias to method '#{e}' deleted since it doesn't exist" if self.verbose
            end
          end
        end
      end
    end
    
    def delete_existing_method_aliases(aliases_hash)
      aliases_hash.each do |k, methods_hash|
        if klass = Object.any_const_get(k)
          methods_hash.each do |a,b|
            if method_exists?(klass,b) && !(alias_map[k].is_a?(Hash) && alias_map[k].values.include?(b))
              methods_hash.delete(a)
              puts "#{klass}: alias '#{b}' deleted since the method already exists" if self.verbose
            end
          end
        end
      end
    end
    
    def to_searchable_array
      @alias_map.map {|klass,method_hash|
        method_hash.map {|k,v| 
          {:class=>klass, :name=>k, :alias=>v}
        }
      }.flatten
    end
    
    def create_method_aliases_per_class(klass, alias_hash)
      eval_string = ""
      alias_hash.each {|original_method, alias_methods|
        alias_methods = [alias_methods] unless alias_methods.is_a?(Array)
        alias_methods.each { |a|
          eval_string += "alias_method :#{a}, :#{original_method}\n"
        }
      }
      if self.is_a?(ClassMethodCreator)
        eval_string = "class <<self\n #{eval_string}\nend"
      end
      klass.class_eval eval_string
    end
    
    def create_method_aliases(aliases)
      aliases ||= {}
      aliases.each { |k,alias_hash|
        if klass = Object.any_const_get(k)
          create_method_aliases_per_class(klass, alias_hash)
        end
      }
    end      
  end
end