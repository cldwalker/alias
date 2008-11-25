#require "g/sensitivehash"
module AliasSearch
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

	def make_searchable_hash_with_default_all(options={})
		if options[:type]
			if @alias_types.include?(options[:type])
				searchable_hash = make_name_alias_hash_by_alias_type(options[:type])
			else
				raise "invalid alias type '#{options[:type]}' given "
			end

		else
			searchable_hash = {}
			@alias_types.each {|e|
				temp_hash = make_name_alias_hash_by_alias_type(e)
				searchable_hash.merge!(temp_hash)
			}
		end
		searchable_hash
	end


	def make_name_alias_hash(hash)
		name_alias_hash = Hash.new
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