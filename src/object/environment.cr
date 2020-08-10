module PheltObject
  class Environment
    property store : Hash(String, PheltObject::Object)
    property outer : Hash(String, PheltObject::Object)?

    def initialize(@outer = nil)
      @store = {} of String => PheltObject::Object
    end

    def get(name : String)
      return @store[name] if @store.has_key? name
      outer = @outer
      unless outer.nil?
        return outer[name] if outer.has_key? name
      end
      return PheltObject::Error.new("error", "error", 0, 0)
    end

    def set(name : String, value : PheltObject::Object)
      @store[name] = value
      return value
    end
  end
end
