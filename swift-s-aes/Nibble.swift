//
//  Nibble.swift
//  swift-s-aes
//
//  Created by Jonathan Chan on 2015-11-16.
//  Copyright © 2015 Jonathan Chan. All rights reserved.
//

import Foundation

/// A four-bit unsigned number from 0 to 15 in the finite field GF(2^4).
struct Nibble {
    // Digits from left to right in a binary representation
    private let zerothBit, firstBit, secondBit, thirdBit: Bit
    
    /// Initialize from an array of Bits.
    init(_ bitArray: [Bit]) {
        if bitArray.count > 0 { zerothBit = bitArray[0] } else { zerothBit = .Zero }
        if bitArray.count > 1 { firstBit = bitArray[1] } else { firstBit = .Zero }
        if bitArray.count > 2 { secondBit = bitArray[2] } else { secondBit = .Zero }
        if bitArray.count > 3 { thirdBit = bitArray[3] } else { thirdBit = .Zero }
    }
    
    /// Initialize from an array of UInt8s.
    init(_ uInt8Array: [UInt8]) {
        if uInt8Array.count > 0 { zerothBit = uInt8Array[0].bitValue } else { zerothBit = .Zero }
        if uInt8Array.count > 1 { firstBit = uInt8Array[1].bitValue } else { firstBit = .Zero }
        if uInt8Array.count > 2 { secondBit = uInt8Array[2].bitValue } else { secondBit = .Zero }
        if uInt8Array.count > 3 { thirdBit = uInt8Array[3].bitValue } else { thirdBit = .Zero }
    }
    
    /// Initialize from a UInt8.
    init(_ uInt8: UInt8) {
        zerothBit = (UInt8(0b1000) & uInt8).bitValue
        firstBit = (UInt8(0b0100) & uInt8).bitValue
        secondBit = (UInt8(0b0010) & uInt8).bitValue
        thirdBit = (UInt8(0b0001) & uInt8).bitValue
    }
    
    /// Returns the UInt8 value of the nibble.
    var uInt8Value: UInt8 {
        var result = UInt8(0)
        if zerothBit == .One { result |= 0b1000 }
        if firstBit == .One { result |= 0b0100 }
        if secondBit == .One { result |= 0b0010 }
        if thirdBit == .One { result |= 0b0001 }
        return result
    }
    
    var uInt8ArrayValue: [UInt8] {
        return [zerothBit.uInt8Value, firstBit.uInt8Value, secondBit.uInt8Value, thirdBit.uInt8Value]
    }
    
    /// Returns a string of the nibble's binary representation.
    var binaryRepresentation: String {
        return "\(zerothBit.uInt8Value)\(firstBit.uInt8Value)\(secondBit.uInt8Value)\(thirdBit.uInt8Value)"
    }
    
    /// The reducing polynomial x^4 + x + 1.
    static let reducingPolynomial: UInt8 = 0b10011
    
    /// The multiplicative inverse of the nibble, calculated through Fermat's Little Theorem.
    func inverted() -> Nibble {
        var product = self
        for _ in 1...(16 - 2 - 1) {
            product = product * self
        }
        return product
    }
    
    func substituted() -> Nibble {
        let table: [Nibble] = [0b1001, 0b0100, 0b1010, 0b1011, 0b1101, 0b0001, 0b1000, 0b0101, 0b0110, 0b0010, 0b0000, 0b0011, 0b1100, 0b1110, 0b1111, 0b0111]
        // Casting to an Int because apparently arrays only support subscripting with Ints lol.
        return table[Int(self.uInt8Value)]
    }
    
    func unsubstituted() -> Nibble {
        let table: [Nibble] = [0b1010, 0b0101, 0b1001, 0b1011, 0b0001, 0b0111, 0b1000, 0b1111, 0b0110, 0b0000, 0b0010, 0b0011, 0b1100, 0b0100, 0b1101, 0b1110]
        // Casting to an Int because apparently arrays only support subscripting with Ints lol.
        return table[Int(self.uInt8Value)]
    }
}

// MARK:- Extensions

// MARK: Nibble operator overloading

/// Allows equality and comparisons between nibbles.
extension Nibble: Equatable, Comparable {
}

/// Compares all the bits of each side.
func ==(lhs: Nibble, rhs: Nibble) -> Bool {
    return lhs.zerothBit == rhs.zerothBit && lhs.firstBit == rhs.firstBit && lhs.secondBit == rhs.secondBit && lhs.thirdBit == rhs.thirdBit
}

/// Compares the leftmost bits of each side first, eventually moving to the right.
func >(lhs: Nibble, rhs: Nibble) -> Bool {
    if lhs.zerothBit == .One && rhs.zerothBit == .Zero { return true }
    else if lhs.firstBit == .One && rhs.firstBit == .Zero { return true }
    else if lhs.secondBit == .One && rhs.secondBit == .Zero { return true }
    else if lhs.thirdBit == .One && rhs.thirdBit == .Zero { return true }
    else { return false }
}

/// Checks for equality or if lhs > rhs.
func >=(lhs: Nibble, rhs: Nibble) -> Bool {
    if lhs == rhs { return true }
    if lhs > rhs { return true }
    return false
}

/// Compares the leftmost bits of each side first, eventually moving to the right.
func <(lhs: Nibble, rhs: Nibble) -> Bool {
    if lhs.zerothBit == .Zero && rhs.zerothBit == .One { return true }
    else if lhs.firstBit == .Zero && rhs.firstBit == .One { return true }
    else if lhs.secondBit == .Zero && rhs.secondBit == .One { return true }
    else if lhs.thirdBit == .Zero && rhs.thirdBit == .One { return true }
    else { return false }
}

/// Checks for equality or if lhs < rhs.
func <=(lhs: Nibble, rhs: Nibble) -> Bool {
    if lhs == rhs { return true }
    if lhs < rhs { return true }
    return false
}

extension Nibble: BitwiseOperationsType {
    static var allZeros: Nibble {
        return self.init(0)
    }
}

/// ANDs each bit.
func &(lhs: Nibble, rhs: Nibble) -> Nibble {
    return Nibble([lhs.zerothBit & rhs.zerothBit, lhs.firstBit & rhs.firstBit, lhs.secondBit & rhs.secondBit, lhs.thirdBit & rhs.thirdBit])
}

/// ORs each bit.
func |(lhs: Nibble, rhs: Nibble) -> Nibble {
    return Nibble([lhs.zerothBit | rhs.zerothBit, lhs.firstBit | rhs.firstBit, lhs.secondBit | rhs.secondBit, lhs.thirdBit | rhs.thirdBit])
}

/// XORs each bit.
func ^(lhs: Nibble, rhs: Nibble) -> Nibble {
    return Nibble([lhs.zerothBit ^ rhs.zerothBit, lhs.firstBit ^ rhs.firstBit, lhs.secondBit ^ rhs.secondBit, lhs.thirdBit ^ rhs.thirdBit])
}

/// Negates each bit.
prefix func ~(x: Nibble) -> Nibble {
    return Nibble([~x.zerothBit, ~x.firstBit, ~x.secondBit, ~x.thirdBit])
}

/// Shifts the bits in lhs left rhs times.
func <<(var lhs: Nibble, rhs: Int) -> Nibble {
    for _ in rhs...1 {
        lhs = Nibble([lhs.firstBit, lhs.secondBit, lhs.thirdBit, .Zero])
    }
    return lhs
}

/// Shifts the bits in lhs right rhs times.
func >>(var lhs: Nibble, rhs: Int) -> Nibble {
    for _ in rhs...1 {
        lhs = Nibble([.Zero, lhs.zerothBit, lhs.firstBit, lhs.secondBit])
    }
    return lhs
}

/// Bitwise addition is equivalent to XOR.
func +(lhs: Nibble, rhs: Nibble) -> Nibble {
    return lhs ^ rhs
}

/// Bitwise subtraction is equivalent to XOR.
func -(lhs: Nibble, rhs: Nibble) -> Nibble {
    return lhs ^ rhs
}

/// Multiplies the nibbles in polynomial form, then reduces modulo the reducing polynomial.
func *(lhs: Nibble, rhs: Nibble) -> Nibble {
    let lhsArray = lhs.uInt8ArrayValue
    let rhsArray = rhs.uInt8ArrayValue
    var product: UInt8 = 0
    product |= (lhsArray[0] & rhsArray[0]) << 6
    product |= ((lhsArray[0] & rhsArray[1]) ^ (lhsArray[1] & rhsArray[0])) << 5
    product |= ((lhsArray[0] & rhsArray[2]) ^ (lhsArray[1] & rhsArray[1]) ^ (lhsArray[2] & rhsArray[0])) << 4
    product |= ((lhsArray[0] & rhsArray[3]) ^ (lhsArray[1] & rhsArray[2]) ^ (lhsArray[2] & rhsArray[1]) ^ (lhsArray[3] & rhsArray[0])) << 3
    product |= ((lhsArray[1] & rhsArray[3]) ^ (lhsArray[2] & rhsArray[2]) ^ (lhsArray[3] & rhsArray[1])) << 2
    product |= ((lhsArray[2] & rhsArray[3]) ^ (lhsArray[3] & rhsArray[2])) << 1
    product |= lhsArray[3] & rhsArray[3]
    
    var remainder = product
    for var i = 2; i >= 0; i-- {
        let shift = UInt8(i)
        if remainder >= 16 << shift {
            remainder ^= Nibble.reducingPolynomial << shift
        }
    }
    return Nibble(remainder)
}

/// Multiplies lhs with the inverse of rhs.
func /(lhs: Nibble, rhs: Nibble) -> Nibble {
    return lhs * rhs.inverted()
}

// MARK: IntegerLiteralConvertible
/// Allows literal initialization of a Nibble.
extension Nibble: IntegerLiteralConvertible {
    typealias IntegerLiteralType = UInt8
    init(integerLiteral value: Nibble.IntegerLiteralType) {
        self.init(value)
    }
}

// MARK: CustomStringConvertible
/// The default String representation of a Nibble is the binary representation.
extension Nibble: CustomStringConvertible {
    var description: String {
        return self.binaryRepresentation
    }
}

// MARK: Others

extension Bit {
    /// Returns a UInt8 value of a Bit.
    private var uInt8Value: UInt8 {
        return self == .Zero ? 0 : 1
    }
}

/// AND implementation for Bit.
private func &(lhs: Bit, rhs: Bit) -> Bit {
    return lhs == .One && rhs == .One ? .One : .Zero
}

/// OR implementation for Bit.
private func |(lhs: Bit, rhs: Bit) -> Bit {
    return lhs == .One || rhs == .One ? .One : .Zero
}

/// Exclusive OR implementation for Bit.
private func ^(lhs: Bit, rhs: Bit) -> Bit {
    return lhs == rhs ? .Zero : .One
}

/// Negates a bit.
private prefix func ~(x: Bit) -> Bit {
    return x == .One ? .Zero : .One
}

extension UInt8 {
    /// Returns a Bit value of a UInt8.
    private var bitValue: Bit {
        return self == 0 ? .Zero : .One
    }
}