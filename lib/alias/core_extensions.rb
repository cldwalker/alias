class Hash
  unless self.method_defined?(:slice)
    # simplified from ActiveSupport
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

class Object
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

class String
  unless self.method_defined?(:camelize)
    #simplified from ActiveSupport
    def camelize
      self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end