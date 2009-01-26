# This is the base creator class from which other *Creator classes inherit.
# Methods this class provides to non-creator classes are: Creator.create()
# Methods this class provides to creator classes to be overridden: @creator.delete_invalid_aliases
# and @creator.create_aliases

module Alias
  class Creator
    
    attr_accessor :verbose, :alias_map, :force, :searched_at, :modified_at
    def initialize(aliases_hash={})
      self.alias_map = aliases_hash
      @verbose = false
      @force = false
    end
    
    def modified_since_last_search?
      (@searched_at && @modified_at) ? (@modified_at > @searched_at) : true
    end
    
    def alias_map=(value)
      @modified_at = Time.now
      @alias_map = value
    end
    
    # Options are:
    # * :auto_alias : Array of constants to alias by shortest available constant. For example,
    #   if the constant A already exists, then Aardvark would be aliased to Aa.
    def self.create(aliases_hash, options={})
      obj = new(aliases_hash)
      obj.verbose = options['verbose'] if options['verbose']
      obj.force = options['force'] if options['force']
      obj.create(obj.alias_map)
      if options['auto_alias']
        obj.alias_map = obj.alias_map.merge(obj.auto_create(options['auto_alias']))
      end
      obj
    end
    
    #needs to return generated aliases_hash
    def auto_create(array_to_alias)
      aliases_hash = generate_aliases(array_to_alias)
      create(aliases_hash)
      aliases_hash
    end
    
    def create(aliases_hash)
      delete_invalid_aliases(aliases_hash)
      delete_existing_aliases(aliases_hash) unless self.force
      self.alias_map = aliases_hash
      
      #td: create method for efficiently removing constants/methods in any namespace
      silence_warnings {
        create_aliases(aliases_hash)
      }
    end
    
    # Should be overridden to delete aliases that point to invalid/nonexistent classes, methods ...
    def delete_invalid_aliases(aliases_hash); end
    
    # Should be overridden to delete aliases that already exist. This method can be bypassed by passing
    # a force option to the creator.
    def delete_existing_aliases(aliases_hash); end
    
    # Must be overridden to use create()
    def create_aliases(aliases_hash); 
      raise "This abstract method must be overridden."
    end
    
    # Must be overridden to use auto_create()
    def generate_aliases(array_to_alias);
      raise "This abstract method must be overridden."
    end
    
    #Should be overridden to support search
    def to_searchable_array; []; end
    
    def delete_invalid_class_keys(klass_hash)
      klass_hash.each {|k,v| 
        if Object.any_const_get(k).nil?
          puts "deleted nonexistent klass #{k} #{caller[2].split(/:/)[2]}" if self.verbose
          klass_hash.delete(k)
        end
      }
    end
    
    private
    def silence_warnings
      old_verbose, $VERBOSE = $VERBOSE, nil
      yield
    ensure
      $VERBOSE = old_verbose
    end
  end
end
