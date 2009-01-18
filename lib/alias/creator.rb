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
    
    def factory_create_aliases(alias_type, aliases_hash)
      creator_class_string = "Alias::#{alias_type.capitalize}Creator"
      if creator_class = Object.any_const_get(creator_class_string)
        creator_class.create(aliases_hash, aliases_hash.slice_off!('auto_alias').merge('verbose'=>true))
      else
        puts "Creator class '#{creator_class_string}' not found." if @verbose
      end
    end
    
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
    
  	def create_klass_aliases(aliases_hash)
  		creator_obj = factory_create_aliases('klass', aliases_hash)
      @klass_aliases.merge! creator_obj.alias_map
  	end

  	def create_instance_aliases(aliases_hash)
  		creator_obj = factory_create_aliases('instance', aliases_hash)
  		@instance_aliases.merge! creator_obj.alias_map
  	end

    def create_constant_aliases(aliases_hash, options={})
      creator_obj = factory_create_aliases('constant', aliases_hash)
      @constant_aliases.merge! creator_obj.alias_map
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

  end
end