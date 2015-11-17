//
//  S-AES.swift
//  swift-s-aes
//
//  Created by Jonathan Chan on 2015-11-17.
//  Copyright © 2015 Jonathan Chan. All rights reserved.
//

import Foundation

// MARK:- NibbleColumn

/// A 1x2 matrix of nibbles, from top to bottom.
struct NibbleColumn {
    private var nibbles: [Nibble]
    
    /// Initializer with an array of nibbles.
    /// Only the first 2 elements in the array are used.
    init(_ nibbles: [Nibble]) {
        self.nibbles = []
        if nibbles.count >= 1 { self.nibbles.append(nibbles[0]) }
        if nibbles.count >= 2 { self.nibbles.append(nibbles[1]) }
    }
    
    /// Switches the positions of the nibbles: AB -> BA.
    func rotated() -> NibbleColumn {
        return [self[1], self[0]]
    }
    
    /// Substitutes each nibble by S-Box substitution.
    func substituted() -> NibbleColumn {
        return [self[0].substituted(), self[1].substituted()]
    }
    
    /// Reverse-substitutes each nibble, undoing `substitution()`.
    func unsubstituted() -> NibbleColumn {
        return [self[0].unsubstituted(), self[1].unsubstituted()]
    }
    
    /// Performs the MixColumns step by matrix multiplication and reduction.
    func mixed() -> NibbleColumn {
        let matrix = NibbleArray(nibbles: [0b0001, 0b0100, 0b0100, 0b0001])
        let result: NibbleColumn = [
            matrix[0][0] * self[0] + matrix[1][0] * self[1],
            matrix[0][1] * self[0] + matrix[1][1] * self[1]
        ]
        return result
    }
    
    /// Performs the InverseMixColumns step by matrix multiplication and reduction, undoing `mixed()`.
    func unmixed() -> NibbleColumn {
        let matrix = NibbleArray(nibbles: [0b1001, 0b0010, 0b0010, 0b1001])
        let result: NibbleColumn = [
            matrix[0][0] * self[0] + matrix[1][0] * self[1],
            matrix[0][1] * self[0] + matrix[1][1] * self[1]
        ]
        return result
    }
}

/// Allows equality checks between columns.
extension NibbleColumn: Equatable {
}

/// Compares each nibble.
func ==(lhs: NibbleColumn, rhs: NibbleColumn) -> Bool {
    return lhs[0] == rhs[0] && lhs[1] == rhs[1]
}

/// The default String representation of a NibbleColumn is the binary representations of each nibble, separated by a space.
extension NibbleColumn: CustomStringConvertible {
    var description: String {
        return "\(self[0]) \(self[1])"
    }
}

/// Allows `aNibbleColumn[i]` notation to reference the nibbles in a column.
extension NibbleColumn: ArrayLiteralConvertible {
    typealias Element = Nibble
    
    init(arrayLiteral nibbles: NibbleColumn.Element...) {
        self.init(nibbles)
    }
    
    subscript(index: Int) -> Nibble {
        get {
            return nibbles[index]
        }
        set(nibble) {
            nibbles[index] = nibble
        }
    }
}

/// XOR each nibble.
func ^(lhs: NibbleColumn, rhs: NibbleColumn) -> NibbleColumn {
    return [lhs[0] ^ rhs[0], lhs[1] ^ rhs[1]]
}

/// Bitwise addition is equivalent to XOR.
func +(lhs: NibbleColumn, rhs: NibbleColumn) -> NibbleColumn {
    return lhs ^ rhs
}

/// Bitwise subtraction is equivalent to XOR.
func -(lhs: NibbleColumn, rhs: NibbleColumn) -> NibbleColumn {
    return lhs ^ rhs
}

// MARK:- NibbleArray

/// A 2x2 matrix of nibbles, from top to bottom and left to right.
struct NibbleArray {
    private var columns: [NibbleColumn]
    
    /// Initializer with an array of nibble columns.
    /// Only the first 2 elements in the array are used.
    init(columns: [NibbleColumn]) {
        self.columns = []
        if columns.count >= 1 { self.columns.append(columns[0]) }
        if columns.count >= 2 { self.columns.append(columns[1]) }
    }
    
    /// Initializer with an array of nibbles, from top to bottom and left to right.
    /// Only the first 4 elements in the array are used.
    init(nibbles: [Nibble]) {
        var column0Nibble0 = Nibble(0)
        var column0Nibble1 = Nibble(0)
        var column1Nibble0 = Nibble(0)
        var column1Nibble1 = Nibble(0)
        if nibbles.count >= 1 { column0Nibble0 = nibbles[0] }
        if nibbles.count >= 2 { column0Nibble1 = nibbles[1] }
        if nibbles.count >= 3 { column1Nibble0 = nibbles[2] }
        if nibbles.count >= 4 { column1Nibble1 = nibbles[3] }
        self.init(columns: [[column0Nibble0, column0Nibble1], [column1Nibble0, column1Nibble1]])
    }
    
    /// Performs the ShiftRows step, switching the places of the nibbles in the bottom row.
    func shiftedRows() -> NibbleArray {
        return [[self[0][0], self[1][1]], [self[1][0], self[0][1]]]
    }
    
    /// Undoes `shiftedRows()`, switching the places of the nibbles in the bottom row.
    /// Coincidentally equivalent to `shiftedRows()`.
    func unshiftedRows() -> NibbleArray {
        return self.shiftedRows()
    }
    
    /// Substitutes each nibble by S-Box substitution.
    func substituted() -> NibbleArray {
        return [self[0].substituted(), self[1].substituted()]
    }
    
    /// Reverse-substitutes each nibble, undoing `substitution()`.
    func unsubstituted() -> NibbleArray {
        return [self[0].unsubstituted(), self[1].unsubstituted()]
    }
    
    /// Performs the MixColumns step by matrix multiplication and reduction.
    func mixed() -> NibbleArray {
        return [self[0].mixed(), self[1].mixed()]
    }
    
    /// Performs the InverseMixColumns step by matrix multiplication and reduction, undoing `mixed()`.
    func unmixed() -> NibbleArray {
        return [self[0].unmixed(), self[1].unmixed()]
    }
    
    /// Performs key expansion given an initial key in `self`.
    func expandedKeys() -> [NibbleArray] {
        let roundConstants: [NibbleColumn] = [[0b0000, 0b0000], [0b1000, 0b0000], [0b0011, 0b0000]]
        let round0 = self
        
        let round1Column0 = round0[1].rotated().substituted() + roundConstants[1] + round0[0]
        let round1Column1 = round1Column0 + round0[1]
        let round1 = NibbleArray(columns: [round1Column0, round1Column1])
        
        let round2Column0 = round1[1].rotated().substituted() + roundConstants[2] + round1[0]
        let round2Column1 = round2Column0 + round1[1]
        let round2 = NibbleArray(columns: [round2Column0, round2Column1])
        
        return [round0, round1, round2]
    }
    
    /// Encrypts `self` by performing the designated steps.
    func encrypt(key initialKey: NibbleArray) -> NibbleArray {
        let plainText = self
        let keys = initialKey.expandedKeys()
        
        let round0 = plainText + keys[0]
        let round1 = round0.substituted().shiftedRows().mixed() + keys[1]
        let round2 = round1.substituted().shiftedRows() + keys[2]
        
        return round2
    }
    
    /// Decrypts `self` by reversing `encrypt(key:)`.
    func decrypt(key initialKey: NibbleArray) -> NibbleArray {
        let cipherText = self
        let keys = initialKey.expandedKeys()
    
        let round2 = (cipherText + keys[2]).unshiftedRows().unsubstituted()
        let round1 = (round2 + keys[1]).unmixed().unshiftedRows().unsubstituted()
        let round0 = round1 + keys[0]
        
        return round0
    }
}

/// Allows equality checks between columns.
extension NibbleArray: Equatable {
}

/// Compares each nibble.
func ==(lhs: NibbleArray, rhs: NibbleArray) -> Bool {
    return lhs[0] == rhs[0] && lhs[1] == rhs[1]
}

/// The default String representation of a NibbleColumn is the binary representations of each nibble, separated by spaces.
extension NibbleArray: CustomStringConvertible {
    var description: String {
        return "\(self[0]) \(self[1])"
    }
}

/// Allows `aNibbleColumn[i]` notation to reference the columns in an array.
extension NibbleArray: ArrayLiteralConvertible {
    typealias Element = NibbleColumn
    
    init(arrayLiteral elements: NibbleArray.Element...) {
        self.init(columns: elements)
    }
    
    subscript(index: Int) -> NibbleColumn {
        get {
            return columns[index]
        }
        set(nibbles) {
            columns[index] = nibbles
        }
    }
}

/// XOR each nibble.
func ^(lhs: NibbleArray, rhs: NibbleArray) -> NibbleArray {
    return [lhs[0] ^ rhs[0], lhs[1] ^ rhs[1]]
}

/// Bitwise addition is equivalent to XOR.
func +(lhs: NibbleArray, rhs: NibbleArray) -> NibbleArray {
    return lhs ^ rhs
}

/// Bitwise subtraction is equivalent to XOR.
func -(lhs: NibbleArray, rhs: NibbleArray) -> NibbleArray {
    return lhs ^ rhs
}
