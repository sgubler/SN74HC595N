import Glibc
import SwiftyGPIO

let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPi3)

var latch = gpios[.P13]!
latch.direction = .OUT
latch.value = 1 
var clock = gpios[.P19]!
clock.direction = .OUT
clock.value = 0
var data = gpios[.P26]!
data.direction = .OUT
data.value = 0

latch.value = 0
latch.value = 1

/*
let register = SN74HC595N(latch:latch, clock:clock, data:data)
var pin = 0
while true {
    var bits = [0,0,0,0,0,0,0,0]
    bits[pin] = 1

    do {
        try register.shiftBits(bits)
    } catch {
        print("Error: \(error)")
    }

    pin = (pin + 1) % 8
    sleep(1)
}


latch.value = 0
for bit in bits.reversed() {
    clock.value = 0
    data.value = bit
    clock.value = 1
    data.value = 0
}
clock.value = 0
latch.value = 1
sleep(5)
*/
