const String = {
    length: fn(self) {
        len(self)
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
    }
}
