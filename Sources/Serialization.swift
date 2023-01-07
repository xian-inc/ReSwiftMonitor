//
//  Serialization.swift
//  ReSwiftMonitor
//
//  Created by 大澤卓也 on 2018/02/01.
//  Copyright © 2018年 Takuya Ohsawa. All rights reserved.
//

import Foundation

public protocol Monitorable {
    var monitorValue: Any { get }
}

extension Monitorable {
   public var monitorValue: Any { return self }
}

extension String: Monitorable {}
extension Int: Monitorable {}
extension CGFloat: Monitorable {}
extension Double: Monitorable {}

extension Array: Monitorable {
    public var monitorValue: Any {
        return self.map { MonitorSerialization.convertValueToDictionary($0) }
    }
}

extension Dictionary: Monitorable {
    public var monitorValue: Any {
        var monitorDict: [String: Any] = [:]

        for (key, value) in self {
            monitorDict["\(key)"] = MonitorSerialization.convertValueToDictionary(value)
        }

        return monitorDict
    }
}

struct MonitorSerialization {
    private init() {}

    static func convertValueToDictionary(_ value: Any) -> Any? {
        if let v = value as? Monitorable {
            return v.monitorValue
        }

        var mirror = Mirror(reflecting: value)

        if mirror.displayStyle == .optional {
            if mirror.children.count == 0 { return "<nil>" }
            let (_, v) = mirror.children.first!
            mirror = Mirror(reflecting: v)
        }

        guard mirror.displayStyle == .struct ||
            mirror.displayStyle == .enum ||
            mirror.displayStyle == .class ||
            mirror.displayStyle == .tuple
        else {
                return String(reflecting: value)
        }

        var result: [String: Any] = [:]

        for (key, child) in mirror.children {
            guard let key = key else {
                continue
            }

            result[key] = MonitorSerialization.convertValueToDictionary(child)
        }

        return result
    }
}
