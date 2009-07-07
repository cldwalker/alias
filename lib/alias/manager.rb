module Alias
  # This class manages creation, searching and saving of aliases. Aliases are created as follows:
  # * Alias hashes are read in by Alias.create and/or input through the console via Alias::Console.create_aliases.
  # * These alias hashes are passed to Alias::Manager.create_aliases. An Alias::Manager object passes each alias hash to 
  #   to the correct Alias::Creator subclass by interpreting the creator type.
  # * Each creator converts their alias hash to an alias hash array and runs them through their defined validators, Alias::Validator objects.
  # * The aliases that meet the validation conditions are then created using Kernel.eval.
  class Manager

    def initialize #:nodoc:
      @creators = {}
      @verbose = false
      @force = false
    end

    # When true, all failed validations print their message. Takes an array of creator type symbols or a boolean to set all creators.
    attr_accessor :verbose
    # When true, optional validations will be skipped. Takes an array of creator type symbols or a boolean to set all creators.
    attr_accessor :force
    # A hash of creator objects that have been used by creator type.
    attr_reader :creators
    # A hash of created aliases by creator type.
    attr_reader :created_aliases

    # The main method for creating aliases. Takes a creator type, a hash of aliases whose format is defined per creator and the
    # following options:
    # 
    # [:verbose] Sets the verbose flag to print a message whenever an alias validation fails. Default is the creator's verbose flag.
    # [:force] Sets the force flag to bypass optional validations. Default is the creator's manager flag.
    # [:pretend] Instead of creating aliases, prints out the ruby code that would be evaluated by Kernel.eval to create the aliases.
    #            Default is false.
    def create_aliases(creator_type, aliases_hash, options={})
      return unless (creator = create_creator(creator_type))
      creator.verbose = options[:verbose] ? options[:verbose] : verbose_creator?(creator_type)
      creator.force = options[:force] ? options[:force] : force_creator?(creator_type)
      creator.create(aliases_hash.dup, options[:pretend] || false)
      true
    rescue Creator::AbstractMethodError
      $stderr.puts $!.message
    rescue Creator::FailedAliasCreationError
      $stderr.puts "'#{creator.class}' failed to create aliases with error:\n#{$!.message}"
    end

    # Creates aliases in the same way as create_aliases while keeping track of what's created. But differs in that creator types can
    # be accessed with just the first few unique letters of a type. For example, you can pass :in to mean :instance_method. Also, the
    # verbose flag is set by default.
    # Examples:
    #   console_create_aliases :in, "String"=>{"to_s"=>"s"}
    #   console_create_aliases :con, {"ActiveRecord::Base"=>"AB"}, :pretend=>true
    def console_create_aliases(creator_type, aliases_hash, options={})
      options = {:verbose=>true}.update(options)
      @created_aliases ||= {}
      creator_type = (all_creator_types.sort.find {|e| e[/^#{creator_type}/] } || creator_type).to_sym
      if create_aliases(creator_type, aliases_hash, options)
        @created_aliases[creator_type] = aliases_hash
        true
      else
        false
      end
    end

    # Saves aliases that were created by console_create_aliases. Can take an optional file to save to. See Alias::Console.save_aliases
    # for default files this method saves to.
    def save_aliases(file=nil)
      if @created_aliases
        Alias.add_to_config_file(@created_aliases, file)
        true
      else
        puts "Didn't save. No created aliases detected."
        false
      end
    end

    # Searches all created alias hashes with a hash or a string. If a string, the alias key searched is :name.
    # If a hash, the key should should be an alias key and the value the search term.
    # All values are treated as regular expressions. Alias keys vary per creator but some of the common ones are :name, :class and :alias.
    # Multiple keys for a hash will AND the searches.
    # Examples:
    #   search 'to_'
    #   search :class=>"Array", :name=>'to'
    def search(search_hash)
      result = nil
      reset_all_aliases
      search_hash = {:name=>search_hash} unless search_hash.is_a?(Hash)
      search_hash.each do |k,v|
        new_result = simple_search(k,v)
        #AND's searches
        result = intersection_of_two_arrays(new_result, result)
      end
      #duplicate results in case they are modified
      result = result.map {|e| e.dup} if result
      result
    end

    # Returns an array of all created alias hashes. The alias hash will have a :type key which contains the creator type it belongs to.
    def all_aliases
      @all_aliases ||= @creators.inject([]) do |t, (type, creator)|
        t += creator.aliases.each {|e| e[:type] = type.to_s}
      end
    end

    #:stopdoc:
    def all_creator_types
      Creator.creators.map {|e| Util.underscore(e.to_s[/::(\w+)Creator$/,1]) }
    end

    def aliases_of(creator_type)
      @creators[creator_type] && @creators[creator_type].aliases
    end

    def verbose_creator?(creator_type)
      @verbose.is_a?(Array) ? @verbose.include?(creator_type.to_sym) : @verbose
    end

    def force_creator?(creator_type)
      @force.is_a?(Array) ? @force.include?(creator_type.to_sym) : @force
    end

    def create_creator(creator_type)
      creator_class_string = "Alias::Creators::#{Util.camelize(creator_type.to_s)}Creator"
      if creator_class = Util.any_const_get(creator_class_string)
        @creators[creator_type.to_sym] ||= creator_class.new
      else
        $stderr.puts "Creator class '#{creator_class_string}' not found."
        nil
      end
    end

    def simple_search(field, search_term)
      all_aliases.select {|e| e[field] =~ /#{search_term}/ }
    end
    
    def intersection_of_two_arrays(arr1, arr2)
      arr2.nil? ? arr1 : arr1.select {|e| arr2.include?(e)}
    end

    def reset_all_aliases; @all_aliases = nil; end
    #:startdoc:
  end
end
