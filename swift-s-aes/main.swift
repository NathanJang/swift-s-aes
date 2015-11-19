//
//  main.swift
//  swift-s-aes
//
//  Created by Jonathan Chan on 2015-11-16.
//  Copyright © 2015 Jonathan Chan. All rights reserved.
//

import Foundation

let plainText = NibbleArray(nibbles: [0b0100, 0b1001, 0b0100, 0b0010]) // "IB" in ASCII
let key = NibbleArray(nibbles: [0b0110, 0b1000, 0b0110, 0b1100]) // "hl" in ASCII
let cipherText = plainText.encrypt(key: key) // Should be 1001 0101 0111 0101
let decrypted = cipherText.decrypt(key: key) // Should be equal to plainText

print("Plain text: \(plainText)")
print("Cipher text: \(cipherText)")
print("Decrypted: \(decrypted)")
print("Decrypted is equal to plain text?: \(plainText == decrypted)") // Should be true
