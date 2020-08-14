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
        return result
    }
}
