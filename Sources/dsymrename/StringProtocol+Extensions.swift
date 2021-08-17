//
//  StringProtocol+Extensions.swift
//  dsymrename
//
//  Created by Stefan Schmitt on 17/08/2021.
//

import Foundation

extension StringProtocol {
    var hexa: [UInt8] {
        var startIndex = self.startIndex
        return (0..<count/2).compactMap { _ in
            let endIndex = index(after: startIndex)
            defer { startIndex = index(after: endIndex) }
            return UInt8(self[startIndex...endIndex], radix: 16)
        }
    }
}
