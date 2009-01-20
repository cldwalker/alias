module Alias
  class InstanceMethodCreator < Creator
    def validate_aliases(aliases_hash)
      clean_invalid_class_keys(aliases_hash)
      clean_invalid_instance_method_keys(aliases_hash)
    end
    
    def clean_invalid_instance_method_keys(alias_hash)
      alias_hash.each do |k, methods|
        methods.keys.each do |e|
          if (klass = Object.any_const_get(k)) && ! klass.method_defined?(e)
            methods.delete(e)
            puts "#{klass}: method '#{e}' not found and thus not aliased" if self.verbose
          end
        end
      end
    end
    
    def create_aliases(aliases_hash)
      create_method_aliases(aliases_hash)
    end
  end
end