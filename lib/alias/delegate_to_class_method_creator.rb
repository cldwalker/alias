module Alias
  class DelegateToClassMethodCreator < Creator
    def create_aliases(aliases)
      aliases ||= {}
      aliases.each {|k, array|
        if klass = Util.any_const_get(k)
          eval_string = ''
          array.each do |aliased_method, delegate_class, delegate_method|
            eval_string += "def #{aliased_method}(*args, &block); #{delegate_class}.__send__(:#{delegate_method}, *args, &block); end\n"
          end
          klass.class_eval eval_string
        end        
      }
    end
    
    def delete_invalid_aliases(aliases_hash)
      delete_invalid_class_keys(aliases_hash)
      delete_invalid_delegate_classes(aliases_hash)
      delete_invalid_delegate_methods(aliases_hash)
    end
    
    def delete_existing_aliases(aliases_hash)
      aliases_hash.each do |k, aliases_array|
        if klass = Util.any_const_get(k)
          aliases_array.each_with_index do |(aliased_method, delegate_class, delegate_method), i|
            #td: prevent alias-created aliases from being deleted here
            if instance_method_exists?(klass, aliased_method)
              puts "#{klass}: alias to method '#{aliased_method}' deleted since it already exists" if self.verbose
              aliases_array.delete_at(i)
            end
          end
        end
      end
    end
    
    def delete_invalid_delegate_classes(aliases_hash)
      aliases_hash.each do |k, aliases_array|
        aliases_array.each_with_index do |(aliased_method, delegate_class, delegate_method), i|
          if Util.any_const_get(delegate_class).nil?
            puts "deleted nonexistent klass #{delegate_class} #{caller[2].split(/:/)[2]}" if self.verbose
            aliases_array.delete_at(i)
          end
        end
      end
    end
    
    def delete_invalid_delegate_methods(aliases_hash)
      aliases_hash.each do |k, aliases_array|
        aliases_array.each_with_index do |(aliased_method, delegate_class, delegate_method), i|
          if klass = Util.any_const_get(delegate_class)
            if ! class_method_exists?(klass, delegate_method)
              aliases_array.delete_at(i)
              puts "#{klass}: alias to method '#{delegate_method}' deleted since it doesn't exist" if self.verbose
            end
          end
        end
      end
    end
    
    def to_searchable_array
      searchable_array = []
      @alias_map.each {|klass,array|
        searchable_array += array.map {|e|
          {:class=>klass, :delegate_name=>e[2],:alias=>e[0],:delegate_class=>e[1]}
        }
      }
      searchable_array
    end
    
    def instance_method_exists?(klass, method)
      klass.method_defined?(method)
    end
    
    def class_method_exists?(klass, method)
      klass.respond_to?(method)
    end
  end
end