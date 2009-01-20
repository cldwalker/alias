module Alias
  class InstanceMethodCreator < Creator
    include Alias::MethodCreatorHelper
    
    def method_exists?(klass, method)
      klass.method_defined?(method)
    end
  end
end