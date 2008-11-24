require "g/forwardable"
require "g/sensitivehash"

# Creates four types of aliases: instance, command, object,and constant.
# All aliases for each type are stored in their respective accessors.
# Here's a brief description of each alias:
# * object: Aliases a class method to a specific object's method. Useful for creating commands
#   in shells ie irb. For example, Pizza::Satchels.eat aliases to @rshell.powerup. Note, that this
#   alias only applies to @rshell and not to other RShell instances.
# * klass: Aliases a class method in the class's namespace. For example,
#   ActiveRecord::Base.find_with_exceedingly_long_method aliases to ActiveRecord::Base.pita_find .
# * instance: Aliases an instance method in the instance method's namespace. For example,
#   @dog.piss_on_grass aliases to @dog.make_friends.
# * constant: Aliases constants. For example, Some::Wonderfully::Long::Constant aliases to S::WLC.
#
# The format to create method aliases are the same:
#   {
#     'Class1'=>{:method11=>:m11},
#     'Class2'=>{:method21=>:m21}
#   }
#
module AliasCreator
	def initialize_aliases #:nodoc:
		@klass_aliases = {}; @instance_aliases = {}; @constant_aliases = {}; @object_aliases = {}
	end

	attr_accessor :klass_aliases, :instance_aliases,:constant_aliases, :object_aliases
	@@alias_types = [:object, :klass, :instance, :constant]

  def alias_types
    @@alias_types
  end
  
	def create_klass_aliases(klass_aliases)
		@klass_aliases.merge! create_aliases(klass_aliases, :klass_alias=>true,:verbose=>true)
	end

	def create_instance_aliases(instance_aliases)
		@instance_aliases.merge! create_aliases(instance_aliases,:verbose=>true)
	end

	# Options are:
	# * :auto_alias : Array of constants to alias by shortest available constant. For example,
	#   if the constant A already exists, then Aardvark would be aliased to Aa.
	def create_constant_aliases(constant_aliases,options={})
		constant_aliases ||= {}
		if options[:auto_alias]
			auto_aliases = make_shortest_aliases(options[:auto_alias])
			constant_aliases.merge!(auto_aliases)
		end
		clean_invalid_klass_keys(constant_aliases)
		constant_aliases.each {|k,v|
			Object.class_eval "#{v} = #{k}"
		}
		@constant_aliases.merge! constant_aliases
	end

	def create_object_aliases(cmd_aliases,object)
		cmd_aliases ||= {}
		#w: currently keeps track of all object methods that are aliased
		clean_invalid_klass_keys(cmd_aliases)
		#no validation until invalid_klasses key option
		import_methods_to_object(object,cmd_aliases, :validate=>false)
		@object_aliases.merge! cmd_aliases
	end

	##query methods

	#used by RShell::Command
	def make_searchable_hash(type) # :nodoc:
		make_name_alias_hash_by_alias_type(type)
	end

	# Searches for a method's alias (method is a symbol).
	# Options are:
	# * :type : Alias type to search under. Alias types are as stated above: constant, instance, klass and object. 
	#    If no alias type is specified, all alias types are searched.
	def findAliases(method_name,options={})
		searchable_hash = make_searchable_hash_with_default_all(options)
		searchable_hash[method_name]
	end

	# Searches for a method name by its alias (alias is a symbol).
	# Options are:
	# * :type : Alias type to search under. Alias types are as stated above: constant, instance, klass and object. If no alias type is specified, all alias types are searched.
	def find_method_by_alias(alias_name,options={})
		searchable_hash = make_searchable_hash_with_default_all(options).invert
		searchable_hash[alias_name]
	end

	def make_shortest_aliases(unaliased_strings,options={})
		options = {:constant=>true}.update(options)
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
				puts "deleted nonexistent klass #{k} #{caller[2].split(/:/)[2]}"
				klass_hash.delete(k)
			end
		}
	end
	
	private

	def make_searchable_hash_with_default_all(options={})
		if options[:type]
			if @@alias_types.include?(options[:type])
				searchable_hash = make_name_alias_hash_by_alias_type(options[:type])
			else
				raise "invalid alias type '#{options[:type]}' given "
			end

		else
			searchable_hash = {}
			@@alias_types.each {|e|
				temp_hash = make_name_alias_hash_by_alias_type(e)
				searchable_hash.merge!(temp_hash)
			}
		end
		searchable_hash
	end


	def make_name_alias_hash(hash)
		name_alias_hash = SensitiveHash.new
		hash.values.each {|e| name_alias_hash.merge(e) }
		name_alias_hash
	end

	def make_name_alias_hash_by_alias_type(type)
		if type.to_s == 'constant'
			searchable_hash = @constant_aliases
		else
			searchable_hash = eval "make_name_alias_hash(@#{type}_aliases) "
		end
		searchable_hash
	end
end

class AliasCreatorI
	extend AliasCreator
end
