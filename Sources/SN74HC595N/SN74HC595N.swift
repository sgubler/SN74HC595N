import SwiftyGPIO

let PINS_PER_CHIP: Int = 8

public enum SN74HC595NError: Error {
    case invalidArrayLength(String)
    case unmanagedPin(String)
}

public class SN74HC595N {
    var latch: GPIO
    var clock: GPIO
    var data: GPIO
    var outputEnable: GPIO?
    var masterReset: GPIO?

    var numberOfChips: Int  = 1

    /**
    Initializes an instance of SN74HC595N

    - Parameters:
	- latch: GPIO pin that locks/unlocks writing to the shift register
	- clock: GPIO pin that shifts bits to the next pin in the register
	- data: GPIO pin that writes the current value to pin 0 on the register
	- outputEnable: Optional GPIO pin that can be used to enable/disable output from the register.
			If this isn't used, the pin must be set to either ground to enable output or
			Vcc to disable output. 
	- masterReset: Optional GPIO pin that can be used to reset all pins on the register the next
		       time the latch pin goes low. If master reset is set low at all it will clear
		       all pin regardless of going high before the latch pin is set low. So... BE
		       CAREFUL if you don't want to lose your current pin values!
	- numberOfChips: Value indicating how many shif registers are daisy chained together. This
			 is multiplied by PINS_PER_CHIP to determine the total number of pins expected.

    - Returns: A shift register.
    */
    public init(latch: GPIO, clock: GPIO, data: GPIO, outputEnable: GPIO? = nil, masterReset: GPIO? = nil, numberOfChips: Int = 1) {
        self.latch = latch
        self.clock = clock
        self.data = data
        self.outputEnable = outputEnable
	self.masterReset = masterReset

	self.numberOfChips = numberOfChips
    }

    /**
    Enables output on the shift register

    - Throws: `SN74HC595NError.unmanagedPin`
	     if `outputEnable` is nil. You
	     can't enable something you 
	     aren't managing...
    */
    public func enableOutput() throws {
	guard let outputEnable = self.outputEnable else {
	    // OE pin isn't being managed so enable can't be performed
	    // To fix this pass a GPIO pin for outputEnable in init
	    throw SN74HC595NError.unmanagedPin("OE pin (13)")
        }
	if outputEnable.value != 0 {
	    outputEnable.value = 0
	}
    }

    /**
    Disables output on the shift register

    - Throws: `SN74HC595NError.unmanagedPin`
	      if `outputEnable` is nil. You
	      can't disable something you
	      aren't managing...
    */
    public func disableOutput() throws {
	guard let outputEnable = self.outputEnable else {
	    // OE pin isn't being managed so disable can't be performed
	    // To fix this pass a GPIO pin for outputEnable in init
	    throw SN74HC595NError.unmanagedPin("OE pin (13)")
	}
	if outputEnable.value != 1 {
	    outputEnable.value = 1
	}
    }

    /**
    Checks if output is enabled

    - Throws: `SN74HC595NError.unmanagedPin`
	      if `outputEnable` is nil. You
	      can't check if something is
	      working if you aren't managing
	      it...
    */
    public func outputIsEnabled() throws -> Bool {
	guard let outputEnable = self.outputEnable else {
	    // OE pin isn't being managed so enabled can't be checked
	    // To fix this pass a GPIO pin for outputEnable in init
	    throw SN74HC595NError.unmanagedPin("OE pin (13)")
	}
	return outputEnable.value == 0
    }

    /**
    Shifts values from array into register

    - Parameters:
	- bits: An array containing the values to write to each pin. A value in bits[0]
		will end up in pin 0 of shift register. The length of the array must
		match `numberOfChips` * `PINS_PER_CHIP` or an error will throw.
	- reset: A boolean checking whether to clear the pins before writing new values.
		 If `masterReset` is nil, changing this to `true` will throw.

    - Throws: `SN74HC595NError.invalidArrayLength`
	      if length of `bits` doesn't match
	      `numberOfChips` * `PINS_PER_CHIP`
    */
    public func shiftBits(_ bits: [Int], reset:Bool = false) throws {
	if bits.count != numberOfChips * PINS_PER_CHIP {
	    throw SN74HC595NError.invalidArrayLength("Length of bits: \(bits.count) must match configured number of pins: \(numberOfChips * PINS_PER_CHIP)")
	}

	if reset {
	    guard let masterReset = self.masterReset else {
		// MR pin isn't being managed so reset cannot be performed
		// To fix this pass a GPIO pin for masterReset in init
		throw SN74HC595Error.unmanagedPin("MR pin (10)")
	    }
	    // set MR pin low to tell the register to clear all values
	    masterReset.value = 0
	    // set MR pin high to stop from clearing on every call
	    masterReset.value = 1
	}

	// set clock and data low
	clock.value = 0
	data.value = 0

	// set latch low
	latch.value = 0

	//loop through bits
	for bit in bits.reversed() {
	    clock.value = 0

	    // write value to pin
	    data.value = bit
	    print("Writing value: \(bit)")
	    // shift bits on upstroke of clock
	    clock.value = 1

	    // clear data pin for next use
	    data.value = 0 
	}
	clock.value = 0

	// set latch high
	latch.value = 1
    } 
}
