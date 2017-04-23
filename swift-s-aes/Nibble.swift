//
//  Nibble.swift
//  swift-s-aes
//
//  Created by Jonathan Chan on 2015-11-16.
//  Copyright © 2015 Jonathan Chan. All rights reserved.
//

/// Implements arithmetic calculations on a nibble instance.
public protocol NibbleOperations {

    /// Returns a string of the nibble's binary representation.
    var binaryRepresentation: String { get }
    
    /// The multiplicative inverse of the nibble, calculated through Fermat's Little Theorem.
    func inverted() -> Self
    
    /// Performs S-Box substitution by matrix multiplication.
    func substituted() -> Self
    
    /// Performs inverse S-Box substitution by matrix multiplication. Undoes `substituted()`.
    func unsubstituted() -> Self
    
    static func ^(lhs: Self, rhs: Self) -> Self

    static func +(lhs: Self, rhs: Self) -> Self

    static func -(lhs: Self, rhs: Self) -> Self

}

/// A shim for the Bit enum since it was removed from Swift 3.
public enum Bit {

    case zero

    case one

}

/// A four-bit unsigned number from 0 to 15 in the finite field GF(2^4) over the reducing polynomial `x^4 + x + 1`.
public struct Nibble {

    /// Digits from left to right in a binary representation (`zerothBit` => 8).
    fileprivate let zerothBit, firstBit, secondBit, thirdBit: Bit
    
    /// Initialize from an array of Bits.
    public init(_ bitArray: [Bit]) {
        if bitArray.count > 0 { zerothBit = bitArray[0] } else { zerothBit = .zero }
        if bitArray.count > 1 { firstBit = bitArray[1] } else { firstBit = .zero }
        if bitArray.count > 2 { secondBit = bitArray[2] } else { secondBit = .zero }
        if bitArray.count > 3 { thirdBit = bitArray[3] } else { thirdBit = .zero }
    }
    
    /// Initialize from an array of UInt8s.
    public init(_ uInt8Array: [UInt8]) {
        if uInt8Array.count > 0 { zerothBit = uInt8Array[0].bitValue } else { zerothBit = .zero }
        if uInt8Array.count > 1 { firstBit = uInt8Array[1].bitValue } else { firstBit = .zero }
        if uInt8Array.count > 2 { secondBit = uInt8Array[2].bitValue } else { secondBit = .zero }
        if uInt8Array.count > 3 { thirdBit = uInt8Array[3].bitValue } else { thirdBit = .zero }
    }
    
    /// Initialize from a UInt8.
    public init(_ uInt8: UInt8) {
        zerothBit = (UInt8(0b1000) & uInt8).bitValue
        firstBit = (UInt8(0b0100) & uInt8).bitValue
        secondBit = (UInt8(0b0010) & uInt8).bitValue
        thirdBit = (UInt8(0b0001) & uInt8).bitValue
    }
    
    /// Returns the UInt8 value of the nibble.
    public var uInt8Value: UInt8 {
        var result = UInt8(0)
        if zerothBit == .one { result |= 0b1000 }
        if firstBit == .one { result |= 0b0100 }
        if secondBit == .one { result |= 0b0010 }
        if thirdBit == .one { result |= 0b0001 }
        return result
    }
    
    /// Returns an array of UInt8s, 0 or 1 (zeroth element => 8).
    public var uInt8ArrayValue: [UInt8] {
        return [zerothBit.uInt8Value, firstBit.uInt8Value, secondBit.uInt8Value, thirdBit.uInt8Value]
    }
    
    /// Returns an array of Bits (zeroth element => 8).
    public var bitArrayValue: [Bit] {
        return [zerothBit, firstBit, secondBit, thirdBit]
    }

}

extension Nibble: NibbleOperations {

    /// Returns a string of the nibble's binary representation.
    public var binaryRepresentation: String {
        return "\(zerothBit.uInt8Value)\(firstBit.uInt8Value)\(secondBit.uInt8Value)\(thirdBit.uInt8Value)"
    }
    
    /// The reducing polynomial x^4 + x + 1.
    fileprivate static let reducingPolynomial: UInt8 = 0b10011
    
    /// The multiplicative inverse of the nibble, calculated through Fermat's Little Theorem.
    public func inverted() -> Nibble {
        var product = self
        for _ in 1...(16 - 2 - 1) {
            product = product * self
        }
        return product
    }
    
    /// Performs S-Box substitution by matrix multiplication.
    public func substituted() -> Nibble {
        let invertedArray = self.inverted().bitArrayValue
        let matrixArray = Nibble(0b0111).bitArrayValue
        let bit0 = matrixArray[3] & invertedArray[0] ^ matrixArray[0] & invertedArray[1] ^ matrixArray[1] & invertedArray[2] ^ matrixArray[2] & invertedArray[3]
        let bit1 = matrixArray[2] & invertedArray[0] ^ matrixArray[3] & invertedArray[1] ^ matrixArray[0] & invertedArray[2] ^ matrixArray[1] & invertedArray[3]
        let bit2 = matrixArray[1] & invertedArray[0] ^ matrixArray[2] & invertedArray[1] ^ matrixArray[3] & invertedArray[2] ^ matrixArray[0] & invertedArray[3]
        let bit3 = matrixArray[0] & invertedArray[0] ^ matrixArray[1] & invertedArray[1] ^ matrixArray[2] & invertedArray[2] ^ matrixArray[3] & invertedArray[3]
        return [bit0, bit1, bit2, bit3] + 0b1001
    }
    
    /// Performs inverse S-Box substitution by matrix multiplication. Undoes `substituted()`.
    public func unsubstituted() -> Nibble {
        let substitutedArray = (self + 0b1001).bitArrayValue
        let inverseMatrixArray = Nibble(0b1101).bitArrayValue
        let bit0 = inverseMatrixArray[3] & substitutedArray[0] ^ inverseMatrixArray[0] & substitutedArray[1] ^ inverseMatrixArray[1] & substitutedArray[2] ^ inverseMatrixArray[2] & substitutedArray[3]
        let bit1 = inverseMatrixArray[2] & substitutedArray[0] ^ inverseMatrixArray[3] & substitutedArray[1] ^ inverseMatrixArray[0] & substitutedArray[2] ^ inverseMatrixArray[1] & substitutedArray[3]
        let bit2 = inverseMatrixArray[1] & substitutedArray[0] ^ inverseMatrixArray[2] & substitutedArray[1] ^ inverseMatrixArray[3] & substitutedArray[2] ^ inverseMatrixArray[0] & substitutedArray[3]
        let bit3 = inverseMatrixArray[0] & substitutedArray[0] ^ inverseMatrixArray[1] & substitutedArray[1] ^ inverseMatrixArray[2] & substitutedArray[2] ^ inverseMatrixArray[3] & substitutedArray[3]
        return Nibble([bit0, bit1, bit2, bit3]).inverted()
    }

}

// MARK:- Extensions

// MARK: Nibble operator overloading

/// Allows equality and comparisons between nibbles.
extension Nibble: Equatable, Comparable {
}

/// Compares all the bits of each side.
public func ==(lhs: Nibble, rhs: Nibble) -> Bool {
    return lhs.zerothBit == rhs.zerothBit && lhs.firstBit == rhs.firstBit && lhs.secondBit == rhs.secondBit && lhs.thirdBit == rhs.thirdBit
}

/// Compares the leftmost bits of each side first, eventually moving to the right.
public func >(lhs: Nibble, rhs: Nibble) -> Bool {
    if lhs.zerothBit == .one && rhs.zerothBit == .zero { return true }
    else if lhs.firstBit == .one && rhs.firstBit == .zero { return true }
    else if lhs.secondBit == .one && rhs.secondBit == .zero { return true }
    else if lhs.thirdBit == .one && rhs.thirdBit == .zero { return true }
    else { return false }
}

/// Compares the leftmost bits of each side first, eventually moving to the right.
public func <(lhs: Nibble, rhs: Nibble) -> Bool {
    if lhs.zerothBit == .zero && rhs.zerothBit == .one { return true }
    else if lhs.firstBit == .zero && rhs.firstBit == .one { return true }
    else if lhs.secondBit == .zero && rhs.secondBit == .one { return true }
    else if lhs.thirdBit == .zero && rhs.thirdBit == .one { return true }
    else { return false }
}

/// Allows bitwise operations.
extension Nibble: BitwiseOperations {

    public static var allZeros: Nibble {
        return self.init(0)
    }

}

/// ANDs each bit.
public func &(lhs: Nibble, rhs: Nibble) -> Nibble {
    return Nibble([lhs.zerothBit & rhs.zerothBit, lhs.firstBit & rhs.firstBit, lhs.secondBit & rhs.secondBit, lhs.thirdBit & rhs.thirdBit])
}

/// ORs each bit.
public func |(lhs: Nibble, rhs: Nibble) -> Nibble {
    return Nibble([lhs.zerothBit | rhs.zerothBit, lhs.firstBit | rhs.firstBit, lhs.secondBit | rhs.secondBit, lhs.thirdBit | rhs.thirdBit])
}

/// XORs each bit.
public func ^(lhs: Nibble, rhs: Nibble) -> Nibble {
    return Nibble([lhs.zerothBit ^ rhs.zerothBit, lhs.firstBit ^ rhs.firstBit, lhs.secondBit ^ rhs.secondBit, lhs.thirdBit ^ rhs.thirdBit])
}

/// Negates each bit.
public prefix func ~(x: Nibble) -> Nibble {
    return Nibble([~x.zerothBit, ~x.firstBit, ~x.secondBit, ~x.thirdBit])
}

/// Shifts the bits in lhs left rhs times.
func <<(lhs: Nibble, rhs: Int) -> Nibble {
    var lhs = lhs
    for _ in 1...rhs {
        lhs = Nibble([lhs.firstBit, lhs.secondBit, lhs.thirdBit, .zero])
    }
    return lhs
}

/// Shifts the bits in lhs right rhs times.
func >>(lhs: Nibble, rhs: Int) -> Nibble {
    var lhs = lhs
    for _ in 1...rhs {
        lhs = Nibble([.zero, lhs.zerothBit, lhs.firstBit, lhs.secondBit])
    }
    return lhs
}

/// Bitwise addition is equivalent to XOR.
public func +(lhs: Nibble, rhs: Nibble) -> Nibble {
    return lhs ^ rhs
}

/// Bitwise subtraction is equivalent to XOR.
public func -(lhs: Nibble, rhs: Nibble) -> Nibble {
    return lhs ^ rhs
}

/// Multiplies the nibbles in polynomial form, then reduces modulo the reducing polynomial.
public func *(lhs: Nibble, rhs: Nibble) -> Nibble {
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
    for i in stride(from: 2, through: 0, by: -1) {
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
extension Nibble: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt8
    
    public init(integerLiteral value: Nibble.IntegerLiteralType) {
        self.init(value)
    }
}

/// Allows initialization by array literal.
extension Nibble: ExpressibleByArrayLiteral {

    public typealias Element = Bit
    
    public init(arrayLiteral bitArray: Nibble.Element...) {
        self.init(bitArray)
    }
    
    subscript(index: Int) -> Nibble.Element {
        return bitArrayValue[index]
    }

}

// MARK: CustomStringConvertible
/// The default String representation of a Nibble is the binary representation.
extension Nibble: CustomStringConvertible {

    public var description: String {
        return self.binaryRepresentation
    }

}

// MARK: Others

extension Bit {

    /// Returns a UInt8 value of a Bit.
    fileprivate var uInt8Value: UInt8 {
        return self == .zero ? 0 : 1
    }

}

/// AND implementation for Bit.
private func &(lhs: Bit, rhs: Bit) -> Bit {
    return lhs == .one && rhs == .one ? .one : .zero
}

/// OR implementation for Bit.
private func |(lhs: Bit, rhs: Bit) -> Bit {
    return lhs == .one || rhs == .one ? .one : .zero
}

/// Exclusive OR implementation for Bit.
private func ^(lhs: Bit, rhs: Bit) -> Bit {
    return lhs == rhs ? .zero : .one
}

/// Negates a bit.
private prefix func ~(x: Bit) -> Bit {
    return x == .one ? .zero : .one
}

extension UInt8 {

    /// Returns a Bit value of a UInt8.
    fileprivate var bitValue: Bit {
        return self == 0 ? .zero : .one
    }

}
