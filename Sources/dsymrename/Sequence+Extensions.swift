//
//  Sequence+Extensions.swift
//  dsymrename
//
//  Created by Stefan Schmitt on 17/08/2021.
//

import Foundation

extension Sequence where Element == UInt8 {
    var data: Data { .init(self) }
    var hexa: String { map { .init(format: "%02x", $0) }.joined() }
}
