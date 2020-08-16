let chars = [" ", ".", ":", "-", "=", "+", "*", "#", "%", "@"]

for(let y = -2.3; y < 0.3; y += 0.1) {
    for(let x = -3.1; x < 0.1; x += 0.04) {
        let zi = 0.0
        let zr = 0.0
        let i = 0.0
        while(i < 100) {
            if (zi*zi*zr*zr >= 4.0) {
                break
            } else {
                zr = zr*zr-zi*zi+x
                zi = 2.0*zr*zi+y
                i = i + 1
            }
        }
        print(chars[i%10])
    }
    puts("")
}
