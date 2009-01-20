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
end
