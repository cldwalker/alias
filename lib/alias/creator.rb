# This is the base creator class from which other *Creator classes inherit.
# Methods this class provides to non-creator classes are: Creator.create()
# Methods this class provides to creator classes to be overridden: @creator.validate_aliases
# and @creator.create_aliases

module Alias
  class Creator
    
    attr_accessor :verbose, :alias_map
    def initialize(aliases_hash={})
      @alias_map = aliases_hash
      @verbose = false
    end
    
    # Options are:
    # * :auto_alias : Array of constants to alias by shortest available constant. For example,
    #   if the constant A already exists, then Aardvark would be aliased to Aa.
    def self.create(aliases_hash, options={})
      obj = new(aliases_hash)
      obj.verbose = options['verbose'] if options['verbose']
      obj.create(obj.alias_map)
      if options['auto_alias']
        obj.alias_map = obj.alias_map.merge(obj.auto_create(options['auto_alias']))
      end
      #td: eval w/ optional safety or just generate eval code
      obj
    end
    
    def auto_create(array_to_alias)
      aliases_hash = generate_aliases(array_to_alias)
      create(aliases_hash)
      aliases_hash
    end
    
    def create(aliases_hash)
      validate_aliases(aliases_hash)
      @alias_map = aliases_hash
      create_aliases(aliases_hash)
    end
    
    # Should be overridden and when validating, remove any invalid aliases from hash.
    def validate_aliases(aliases_hash); end
    
    # Must be overridden to use create()
    def create_aliases(aliases_hash); 
      raise "This abstract method must be overridden."
    end
    
    # Must be overridden to use auto_create()
    def generate_aliases(array_to_alias);
      raise "This abstract method must be overridden."
    end
    
    #clean hash of undefined classes
    def clean_invalid_klass_keys(klass_hash)
      klass_hash.each {|k,v| 
        if Object.any_const_get(k).nil?
          puts "deleted nonexistent klass #{k} #{caller[2].split(/:/)[2]}" if self.verbose
          klass_hash.delete(k)
        end
      }
    end
    
    def create_method_aliases_for_klass(klass, alias_hash, options)
      eval_string = ""
      alias_hash.each {|original_method, alias_methods|
        alias_methods = [alias_methods] unless alias_methods.is_a?(Array)
        alias_methods.each { |a|
          eval_string += "alias_method :#{a}, :#{original_method}\n"
        }
      }
      if self.is_a?(KlassCreator)
        eval_string = "class <<self\n #{eval_string}\nend"
      end
      klass.class_eval eval_string
    end
    
    def create_method_aliases(aliases,options={})
      aliases ||= {}
      aliases.each { |k,alias_hash|
        klass = Object.any_const_get(k)
        create_method_aliases_for_klass(klass, alias_hash, options)
      }
    end
    
  end
end
