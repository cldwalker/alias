module Alias
  class InstanceCreator < BaseCreator
    def validate_aliases(*args); end
    
    def create_aliases(aliases_hash)
      create_method_aliases(aliases_hash, :verbose=>self.verbose)
    end
  end
end