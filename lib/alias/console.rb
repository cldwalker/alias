#Usage: include Alias::Console wherever you want to use these methods
module Alias
  module Console
    def self.included(base)
      base.extend self
    end
    
    def create(*args)
      Alias.manager.create_aliases(*args)
    end
    
    #options: type, raw, class, sort
    #s 'man', :t=>'instance_method'
    #s /ma/, :r=>true
    def search(*args)
      options = args[-1].is_a?(Hash) ? args[-1].slice_off!(:raw, :sort) : {}
      if args[0] && ! (args[0].is_a?(Hash) && args[0].empty?)
        if args[0].is_a?(String) or args[0].is_a?(Regexp)
          search_hash = {:name=>args[0]}
          search_hash.merge!(args[1]) if args[1].is_a?(Hash)
        elsif args[0].is_a?(Hash)
          search_hash = args[0]
        end
        result = Alias.manager.search(search_hash)
      else
        result = Alias.manager.list
      end
      
      if options[:sort]
        result = result.sort {|a,b| 
          (a[options[:sort]].nil? || b[options[:sort]].nil?) ? 1 :
            (a[options[:sort]]) <=> b[options[:sort]]
        }
      end
      if options[:raw]
        result
      else
        format_search(result, options)
        nil
      end
    end
    
    def format_search(result, options)
      body = ''
      result.each do |e|
        h = e.slice_off!(:name, :alias)
        body += "#{h[:alias]} = #{h[:name]} ;   " + e.map {|k,v| "#{k}: #{v}"}.join(", ") + "\n"
      end
      puts body
    end    
  end
end