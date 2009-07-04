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
    def symbolize_keys(hash)
      hash.inject({}) do |options, (key, value)|
        options[key.to_sym] = value
        options
      end
    end

    def any_const_get(name)
      Util.const_cache[name] ||= Util.uncached_any_const_get(name)
    end

    def const_cache
      @const_cache ||= {}
    end

    def uncached_any_const_get(name)
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

    def make_shortest_aliases(unaliased_strings)
      shortest_aliases = {}
      possible_alias = ''
      unaliased_strings.each {|s|
        possible_alias = ''
        s.split('').each { |e|
          possible_alias += e
          if ! shortest_aliases.values.include?(possible_alias)
            shortest_aliases[s] = possible_alias
            break
          end
        }
      }
      shortest_aliases
    end

    def silence_warnings
      old_verbose, $VERBOSE = $VERBOSE, nil
      yield
    ensure
      $VERBOSE = old_verbose
    end
  end
end