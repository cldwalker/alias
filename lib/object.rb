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
