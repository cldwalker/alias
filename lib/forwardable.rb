#Creates instance, command and klass aliases. Some of the aliasing is based on forwardable.rb.
require 'forwardable'
require 'g/object'
require 'g/array'

class Object #:nodoc:
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
				puts "Class #{k} not found and no aliases created" #if options[:verbose]
			end

		}
	end

  #?:not sure if this is used
	def import_method_to_class(method,export_class,import_class=Object)
	  import_class.class_eval %[
	    def #{method}(*args)
	      #{Object.const_get(export_class)}.__send__(:#{method},*args)
	    end
	  ]
	end

	def import_methods_to_object(obj,klass_methods={},options={})
		obj.extend SingleForwardable
		export_many(obj,klass_methods,options)
	end
		
	#note: invalid klass keys are kept
	def export_many(obj,klass_methods={},options={})
	  options = {:validate=>true}.update(options)
    klass_methods.each { |k,m|
      valid_methods = (options[:validate]) ? validate_klass_methods(k,m) : m
      if valid_methods.empty?
        klass_methods.delete(k)
      else
          #modify hash with valid methods
          klass_methods[k] = (valid_methods.is_a?(Array) && valid_methods.size == 1) ? valid_methods[0] : valid_methods
          export(obj,k,valid_methods)
      end
    }
  end
		
	def validate_klass_methods(klass, methods)
	  real_klass = Object.any_const_get(klass)
	  if methods.is_a?(Hash)
	    accepted_h, rejected_h = methods.partition {|k,v| real_klass.respond_to?(k)}
	    rejected = rejected_h.map {|e| e[0]}
	    accepted = accepted_h.aoa_to_hash
	  else
	    accepted, rejected = methods.partition {|e| real_klass.respond_to?(e) }
	  end
	  puts "Attempted import of nonexistent methods for class '#{klass}': #{rejected.inspect}" unless rejected.empty?
		
		accepted
	end
	
	#has no method validation
	def export(obj,klass,methods=[])
	  real_klass = Object.any_const_get(klass)
	  #prevent nonexistent classes from being used
	  return nil unless real_klass
	  	  
		if methods.class == Hash
			methods.each {|k,v| obj.def_delegator(real_klass,k,v) }
		else
			obj.def_delegators(real_klass,*methods)
		end
	end

end
