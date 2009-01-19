#Creates instance, command and klass aliases. Some of the aliasing is based on forwardable.rb.
# require 'forwardable'
# require 'g/array'

class Object #:nodoc:
  def self.any_const_get(name)
    begin
    klass = Object
    name.split('::').each {|e|
      klass = klass.const_get(e)
    }
    klass
    rescue; nil; end
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

class Hash
  unless self.method_defined?(:slice)
    #from ActiveSupport
    def slice(*keys)
      reject { |key,| !keys.include?(key) }
    end
  end
  
  def slice_off!(*keys)
    new_hash = slice(*keys)
    keys.each {|e| self.delete(e)}
    new_hash
  end
end
