module Alias
  class BaseCreator
    
    attr_reader :alias_map
    attr_accessor :verbose
    def initialize(aliases_hash={})
      @alias_map = aliases_hash
    end
    
    # Options are:
  	# * :auto_alias : Array of constants to alias by shortest available constant. For example,
  	#   if the constant A already exists, then Aardvark would be aliased to Aa.
    def self.create(aliases_hash, options={})
      obj = new(aliases_hash)
      obj.create(obj.alias_map)
      if options['auto_alias']
        obj.alias_map.merge obj.auto_create(options['auto_alias'])
      end
      obj.verbose = options['verbose'] if options['verbose']
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
      create_aliases(aliases_hash)
    end
    
    def validate_aliases(aliases_hash)
      raise "This is an abstract method and should be overridden."
    end
    
    def create_aliases(aliases_hash)
      raise "This is an abstract method and should be overridden."
    end
    
    def clean_invalid_klass_keys(klass_hash)
  		#clean hash of undefined classes
  		klass_hash.each {|k,v| 
  			if Object.any_const_get(k).nil?
  				puts "deleted nonexistent klass #{k} #{caller[2].split(/:/)[2]}" if self.verbose
  				klass_hash.delete(k)
  			end
  		}
  	end
  	
  	#td: refactor
  	def create_method_aliases(aliases,options={})
  		aliases ||= {}
  		aliases.each { |k,alias_hash|
  			klass = Object.any_const_get(k)
  			if klass
  				eval_string = ""
  				alias_hash.each {|original_method, alias_methods|
  					alias_methods = [alias_methods] unless alias_methods.is_a?(Array)

  					if ((options[:klass_alias] && ! klass.respond_to?(original_method)) ||
  						( ! options[:klass_alias] && ! klass.method_defined?(original_method)) )
  						puts "#{klass}: method '#{original_method}' not found and thus not aliased" if options[:verbose]
  						next
  					end

  					alias_methods.each { |a|
  						eval_string += "alias_method :#{a}, :#{original_method}\n"
  					}
  				}
  				if options[:klass_alias]
  					eval_string = "class <<self\n #{eval_string}\nend"
  				end
  				klass.class_eval eval_string
  			else
  				puts "Class #{k} not found and no aliases created" if options[:verbose]
  			end

  		}
  	end
  	
  end
end
