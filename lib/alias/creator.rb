# Creates four types of aliases: instance, command, object,and constant.
# All aliases for each type are stored in their respective accessors.
# Here's a brief description of each alias:
# * object: Aliases a class method to another object's method. Useful for creating commands
#   in shells ie irb. For example, one could alias Pizza::Satchels.eat to @shell.eat_pizza. Note, that this
#   alias would only applies to @shell and no other objects having the same class as @shell.
# * klass: Aliases a class method in the class's namespace. For example, one could alias
#   ActiveRecord::Base.find_with_exceedingly_long_method to ActiveRecord::Base.pita_find .
# * instance: Aliases an instance method in the instance method's namespace. For example, one could alias
#   @dog.piss_on_grass to @dog.make_friends.
# * constant: Aliases constants. For example, one could alias Some::Wonderfully::Long::Constant to SWLC.
#
# The format to create method aliases are the same:
#   {
#     'Class1'=>{:method11=>:m11},
#     'Class2'=>{:method21=>:m21}
#   }
#
module Alias
  class Creator
  
  	def initialize #:nodoc:
  		@klass_aliases = {}; @instance_aliases = {}; @constant_aliases = {}; @object_aliases = {}
    	@alias_types = [:object, :klass, :instance, :constant]
    	@verbose = true
  	end

  	attr_accessor :klass_aliases, :instance_aliases,:constant_aliases, :object_aliases, :alias_types

    def create_aliases_for_type(alias_type, aliases_hash)
      case alias_type
      when 'klass'
        create_klass_aliases(aliases_hash)
      when 'constant'
        create_constant_aliases(aliases_hash)
      when 'instance'
        create_instance_aliases(aliases_hash)
      end
    end
    
  	def create_klass_aliases(klass_aliases)
  		@klass_aliases.merge! create_aliases(klass_aliases, :klass_alias=>true,:verbose=>@verbose)
  	end

  	def create_instance_aliases(instance_aliases)
  		@instance_aliases.merge! create_aliases(instance_aliases,:verbose=>@verbose)
  	end

  	# Options are:
  	# * :auto_alias : Array of constants to alias by shortest available constant. For example,
  	#   if the constant A already exists, then Aardvark would be aliased to Aa.
  	def create_constant_aliases(constant_aliases,options={})
  		constant_aliases ||= {}
  		if options[:auto_alias]
  			auto_aliases = make_shortest_aliases(options[:auto_alias], :constant=>true)
  			constant_aliases.merge!(auto_aliases)
  		end
  		clean_invalid_klass_keys(constant_aliases)
  		constant_aliases.each {|k,v|
  			Object.class_eval "#{v} = #{k}"
  		}
  		@constant_aliases.merge! constant_aliases
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

  	##query methods

  	def make_shortest_aliases(unaliased_strings,options={})
  		options = {:constant=>false}.update(options)
  		shortest_aliases = {}
  		possible_alias = ''
  		unaliased_strings.each {|s|
  			possible_alias = ''
  			s.split('').each { |e|
  				possible_alias += e	
  				if ! shortest_aliases.values.include?(possible_alias) && ! (options[:constant] && Object.const_defined?(possible_alias))
  					shortest_aliases[s] = possible_alias
  					break
  				end
  			}
  		}

  		shortest_aliases
  	end

  	def clean_invalid_klass_keys(klass_hash)
  		#clean hash of undefined classes
  		klass_hash.each {|k,v| 
  			if Object.any_const_get(k).nil?
  				puts "deleted nonexistent klass #{k} #{caller[2].split(/:/)[2]}" if @verbose
  				klass_hash.delete(k)
  			end
  		}
  	end
	
  	private
	
  	def create_aliases(aliases,options={})
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