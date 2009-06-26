module Alias
  module Util
    extend self
    # simplified from ActiveSupport
    def slice(hash, *keys)
      hash.reject {|key,| !keys.include?(key) }
    end

    def slice_off!(hash, *keys)
      new_hash = slice(hash,*keys)
      keys.each {|e| hash.delete(e)}
      new_hash
    end

    #from ActiveSupport
    def stringify_keys(hash)
      hash.inject({}) do |options, (key, value)|
        options[key.to_s] = value
        options
      end
    end

    def any_const_get(name)
      begin
        klass = Object
        name.split('::').each {|e|
          klass = klass.const_get(e)
        }
        klass
      rescue
        nil
      end
    end

    #simplified from ActiveSupport
    def camelize(string)
      string.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end