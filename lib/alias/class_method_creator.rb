module Alias
  class ClassMethodCreator < Creator
    include Alias::MethodCreatorHelper
    
    def method_exists?(klass, method)
      klass.respond_to?(method)
    end
  end
end