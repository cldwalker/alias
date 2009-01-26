# This class manages creation of aliases.
module Alias
  class Manager
  
    def initialize #:nodoc:
      @alias_creators = {}
      @verbose = false
      @force = false
    end

    attr_accessor :alias_creators, :verbose, :force
    def alias_types; @alias_creators.keys; end
    def alias_creator_objects; @alias_creators.values; end
    
    def factory_create_aliases(alias_type, aliases_hash)
      creator_class_string = "Alias::#{alias_type.camelize}Creator"
      create_options = aliases_hash.slice_off!('auto_alias', 'verbose', 'force')
      create_options['verbose'] = @verbose unless create_options.has_key?('verbose')
      if creator_class = Object.any_const_get(creator_class_string)
        creator_class.create(aliases_hash, create_options)
      else
        puts "Creator class '#{creator_class_string}' not found." if @verbose
        nil
      end
    end
    
    def create_aliases(alias_type, aliases_hash)
      aliases_hash = aliases_hash.dup
      if obj = factory_create_aliases(alias_type.to_s, aliases_hash.dup)
        @alias_creators[alias_type.to_sym] ||= obj
        
        accessor_method = "#{alias_type}_aliases"
        if ! respond_to?(accessor_method)
          self.class.send :attr_accessor, accessor_method
        end
        self.send("#{accessor_method}=", {}) if self.send(accessor_method).nil?
        self.send(accessor_method).merge! obj.alias_map
      end
    end
    
    def search(field, search_term)
      result = searchable_aliases.select {|e| 
        search_term.is_a?(Regexp) ? e[field] =~ search_term : e[field] == search_term
      }
      alias_creator_objects.each {|e| e.searched_at = Time.now }
      result
    end
    
    def searchable_aliases
      # @searchable_aliases = nil if alias_creator_objects.any? {|e| e.modified_since_last_search? }
      @searchable_aliases = create_searchable_aliases(@searchable_aliases)
    end
        
    def create_searchable_aliases(searchable_array=nil)
      searchable_array ||= []
      @alias_creators.map do |type, creator|
        if creator.modified_since_last_search?
          searchable_array.delete_if {|e| e[:type] == type.to_s}
          new_arr = creator.to_searchable_array.each {|e| e[:type] = type.to_s}
          searchable_array += new_arr
        end
      end
      searchable_array
    end
  end
end
