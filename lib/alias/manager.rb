module Alias
  # This class manages creation of aliases.
  class Manager

    def initialize #:nodoc:
      @alias_creators = {}
      @verbose = false
      @force = false
    end

    attr_accessor :alias_creators, :verbose, :force

    def create_aliases(creator_type, aliases_hash, options={})
      return unless (creator = create_creator(creator_type))
      creator.verbose = options[:verbose] ? options[:verbose] : verbose_creator?(creator_type)
      creator.force = options[:force] ? options[:force] : force_creator?(creator_type)
      creator.create(aliases_hash.dup, options[:pretend] || false)
    rescue Creator::AbstractMethodError
      $stderr.puts "'#{creator.class}' doesn't have the necessary methods defined."
    rescue Creator::FailedAliasCreationError
      $stderr.puts "'#{creator.class}' failed to create aliases with error:\n#{$!.message}"
    end

    #:stopdoc:
    def alias_types; @alias_creators.keys; end
    def alias_creator_objects; @alias_creators.values; end
    def alias_map(type)
      @alias_creators[type] && @alias_creators[type].alias_map
    end

    def verbose_creator?(creator_type)
      @verbose.is_a?(Array) ? @verbose.include?(creator_type.to_sym) : @verbose
    end

    def force_creator?(creator_type)
      @force.is_a?(Array) ? @force.include?(creator_type.to_sym) : @force
    end

    def create_creator(alias_type)
      creator_class_string = "Alias::#{Util.camelize(alias_type.to_s)}Creator"
      if creator_class = Util.any_const_get(creator_class_string)
        @alias_creators[alias_type.to_sym] ||= creator_class.new
      else
        $stderr.puts "Creator class '#{creator_class_string}' not found."
        nil
      end
    end
    
    def search(search_hash)
      result = nil
      search_hash.each do |k,v|
        new_result = simple_search(k,v)
        #AND's searches
        result = intersection_of_two_arrays(new_result, result)
      end
      #duplicate results in case they are modified
      result = result.map {|e| e.dup} if result
      result
    end

    def simple_search(field, search_term)
      result = all_aliases.select {|e|
        search_term.is_a?(Regexp) ? e[field] =~ search_term : e[field] == search_term
      }
      result
    end
    
    def intersection_of_two_arrays(arr1, arr2)
      arr2.nil? ? arr1 : arr1.select {|e| arr2.include?(e)}
    end
    
    def all_aliases
      @alias_creators.inject([]) do |t, (type, creator)|
        t += creator.alias_map.each {|e| e[:type] = type.to_s}
      end
    end
    #:startdoc:
  end
end
