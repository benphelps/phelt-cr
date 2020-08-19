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
        let length = len(self) - 1
        for (let i = length; i >= 0; i -= 1) {
            result += self[i]
        }
        result
    }
}

const Number = {
    pow: fn(self, to) {
        let value = self
        for(let i = 0; i < (to - 1); i += 1) {
            value *= self
        }
        return value
    }
}

const Array = {
    length: fn(self) {
        object_length(self)
    },
    first: fn(self) {
        array_first(self)
    },
    rest: fn(self) {
        array_rest(self)
    },
    last: fn(self) {
        array_last(self)
    },
    push: fn(self, item) {
        array_push(self, item)
    },
    pop: fn(self) {
        array_pop(self)
    },
    shift: fn(self) {
        array_shift(self)
    },
    unshift: fn(self, item) {
        array_unshift(self, item)
    },
    map: fn(self, callback) {
        let iter = fn(array, accumulated) {
            if (object_length(array) == 0) {
                accumulated
            } else {
                iter(array_rest(array), array_push(accumulated, callback(array_first(array))))
            }
        }
        iter(self, [])
    },
    reduce: fn(self, initial, callback) {
        let iter = fn(array, result) {
            if (object_length(array) == 0) {
                result
            } else {
                iter(array_rest(array), callback(result, array_first(array)));
            }
        }

        iter(self, initial);
    },
    sum: fn(self) {
        Array["reduce"](self, 0, fn(i, e) { i + e })
    }
}
