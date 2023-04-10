//
//  HSMockManager.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/4.
//

import Foundation

struct HSMockManager {
    static let `default` = HSMockManager()
    var parser: HSMockParser = HSMockParser(fileName: "MockConfig")
    var requestDuration: Int? {
        return parser.maxTimeUse
    }
    init() {
        
    }
    func hasMockData(for key: String) -> Bool {
        parser.hasMockData(for: key)
    }
    func mockData(for key: String) -> String? {
        parser.mockData(for: key)
    }
}

