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
      return get_from_outer(name, @outer)
    end

    def get_from_outer(name : ::String, outer : PheltObject::Environment?)
      if outer.is_a? PheltObject::Environment
        return outer.store[name] if outer.store.has_key? name
        if outer.outer.is_a? PheltObject::Environment
          return get_from_outer(name, outer.outer)
        end
      end
      return PheltObject::Error.new("error", "error", 0, 0)
    end

    def exists?(name : ::String) : Bool
      return true if @store.has_key? name
      if find_outer(name, @outer)
        return true
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

    def find_outer(name : ::String, outer : PheltObject::Environment?) : PheltObject::Environment?
      if outer.is_a? PheltObject::Environment
        return outer if outer.store.has_key? name
        if outer.outer.is_a? PheltObject::Environment
          return find_outer(name, outer.outer)
        end
      end
      return nil
    end

    def set(name : ::String, value : PheltObject::Object, const = false)
      @constants << name if const

      if @scoped
        @store[name] = value
      else
        if outer = find_outer(name, @outer)
          outer.store[name] = value
        else
          @store[name] = value
        end
      end

      return value
    end
  end
end
