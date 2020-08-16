module PheltObject
  class Environment
    property external_loaded : Bool = false
    property constants : ::Array(::String) = [] of ::String
    property store : ::Hash(::String, PheltObject::Object)
    property outer : PheltObject::Environment?
    property scoped : Bool

    def initialize(@outer = nil, @scoped = false)
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

      if @scoped
        @store[name] = value
      else
        outer = @outer
        if !outer.nil?
          if outer.store.has_key? name
            outer.store[name] = value
          else
            @store[name] = value
          end
        else
          @store[name] = value
        end
      end

      return value
    end
  end
end
