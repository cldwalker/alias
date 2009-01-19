# This class manages creation of aliases.
module Alias
  class Manager
  
    def initialize #:nodoc:
      @aliases = {}
      @verbose = true
    end

    attr_accessor :aliases
    def alias_types; @aliases.keys; end
    
    def factory_create_aliases(alias_type, aliases_hash)
      creator_class_string = "Alias::#{alias_type.capitalize}Creator"
      if creator_class = Object.any_const_get(creator_class_string)
        creator_class.create(aliases_hash, aliases_hash.slice_off!('auto_alias').merge('verbose'=>true))
      else
        puts "Creator class '#{creator_class_string}' not found." if @verbose
        nil
      end
    end
    
    def create_aliases(alias_type, aliases_hash)
      aliases_hash = aliases_hash.dup
      if obj = factory_create_aliases(alias_type.to_s, aliases_hash.dup)
        @aliases[alias_type.to_sym] ||= obj
        
        accessor_method = "#{alias_type}_aliases"
        if ! respond_to?(accessor_method)
          self.class.send :attr_accessor, accessor_method
        end
        self.send("#{accessor_method}=", {}) if self.send(accessor_method).nil?
        self.send(accessor_method).merge! obj.alias_map
      end
    end
    
    #TODO
    # def create_object_aliases(cmd_aliases,object)
    #   cmd_aliases ||= {}
    #   #w: currently keeps track of all object methods that are aliased
    #   clean_invalid_klass_keys(cmd_aliases)
    #   #no validation until invalid_klasses key option
    #   import_methods_to_object(object,cmd_aliases, :validate=>false)
    #   @object_aliases.merge! cmd_aliases
    # end

  end
end
