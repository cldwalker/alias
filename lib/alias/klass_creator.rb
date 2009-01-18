module Alias
  class KlassCreator < BaseCreator
    def validate_aliases(*args); end
    
    def create_aliases(aliases_hash)
      create_method_aliases(aliases_hash, :klass_alias=>true,:verbose=>self.verbose)
    end
  end
end