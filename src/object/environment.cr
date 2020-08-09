module PheltObject
  class Environment
    property store : Hash(String, PheltObject::Object)

    def initialize
      @store = {} of String => PheltObject::Object
    end

    def get(name : String)
      return @store[name] if @store.has_key? name
      return PheltObject::Error.new("error", "error", 0, 0)
    end

    def set(name : String, value : PheltObject::Object)
      @store[name] = value
      return value
    end
  end
end
