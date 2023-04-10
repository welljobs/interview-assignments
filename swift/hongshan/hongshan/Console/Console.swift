//
//  Console.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/4.
//

import Foundation

public class Console {
#if DEBUG
    static let DEBUG = true
#else
    static let DEBUG = false
#endif
    
    enum LogLevel: Int, Comparable {
        case debug
        case info
        case warning
        case error
        
        static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    static func log(tag: String = "Console", level: LogLevel = .debug, msg: String) {
        let filterLevel: LogLevel = DEBUG ? .debug : .warning
        if level >= filterLevel {
            print("[\(tag)]: \(msg)")
        }
    }
}
