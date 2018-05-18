//
//  EQEnumExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/18.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
protocol EnumCollection: Hashable {}
extension EnumCollection {
    static func cases() -> AnySequence<Self> {
        typealias S = Self
        return AnySequence { () -> AnyIterator<S> in
            var raw = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current
            }
        }
    }
}
