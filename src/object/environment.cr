module PheltObject
  class Environment
    property constants : ::Array(::String) = [] of ::String
    property store : ::Hash(::String, PheltObject::Object)
    property outer : PheltObject::Environment?

    def initialize(@outer = nil)
      @store = {} of ::String => PheltObject::Object
    end

    def get(name : ::String)
      return @store[name] if @store.has_key? name
      outer = @outer
      unless outer.nil?
        return outer.store[name] if outer.store.has_key? name
      end
      return PheltObject::Error.new("error", "error", 0, 0)
    end

    def exists?(name : ::String) : Bool
      return true if @store.has_key? name
      outer = @outer
      unless outer.nil?
        return true if outer.store.has_key? name
      end
      return false
    end

    def constant?(name : ::String) : Bool
      return true if @constants.includes? name
      outer = @outer
      unless outer.nil?
        return true if outer.constants.includes? name
      end
      return false
    end

    def set(name : ::String, value : PheltObject::Object, const = false)
      @constants << name if const
      @store[name] = value
      return value
    end
  end
end
