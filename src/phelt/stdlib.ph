const Object = {
    type: fn(self) {
        object_type(self)
    }
}

const String = {
    length: fn(self) {
        object_length(self)
    },
    reverse: fn(self) {
        let result = ""
        let length = self.length - 1
        for (let i = length; i >= 0; i--) {
            result += self[i]
        }
        return result
    }
}

const Number = {
    pow: fn(self, to) {
        let value = self
        for(let i = 0; i < (to - 1); i++) {
            value *= self
        }
        return value
    }
}

const Hash = {
    has_key?: fn(self,  index) {
        if (self[index] != null) {
            return true
        }
        return false
    }
}

const Array = {
    length: fn(self) {
        return object_length(self)
    },
    first: fn(self) {
        return array_first(self)
    },
    rest: fn(self) {
        return array_rest(self)
    },
    last: fn(self) {
        return array_last(self)
    },
    push: fn(self, item) {
        return array_push(self, item)
    },
    pop: fn(self) {
        return array_pop(self)
    },
    shift: fn(self) {
        return array_shift(self)
    },
    unshift: fn(self, item) {
        return array_unshift(self, item)
    },
    map: fn(self, callback) {
        let iter = fn(array, accumulated) {
            if (object_length(array) == 0) {
                return accumulated
            } else {
                return iter(array_rest(array), array_push(accumulated, callback(array_first(array))))
            }
        }
        return iter(self, [])
    },
    reduce: fn(self, initial, callback) {
        let iter = fn(array, result) {
            if (object_length(array) == 0) {
                return result
            } else {
                return iter(array_rest(array), callback(result, array_first(array)));
            }
        }

        return iter(self, initial);
    },
    sum: fn(self) {
        return Array["reduce"](self, 0, fn(i, e) { i + e })
    }
}
