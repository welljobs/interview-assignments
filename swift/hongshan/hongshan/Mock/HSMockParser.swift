//
//  HSMockParser.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/4.
//

import Foundation

struct HSMockConfigrationItem {
    var mockEnable: Bool?
    var fileArray: [HSMockConfigrationFile]?
    
    struct HSMockConfigrationFile {
        var fileName: String?
        var percent: Int?
    }
}

class HSMockParser {
    fileprivate var mockEnable: Bool = false
    var maxTimeUse: Int?
    fileprivate var configDic: [String: HSMockConfigrationItem] = [:]
    init(fileName: String) {
        setup(fileName: fileName)
    }
    func setup(fileName: String) {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "plist") else {
            fatalError("not found file path.")
        }
        guard let dict = NSDictionary(contentsOfFile: filePath) else { return }
        //  外部配置是否开启Mock，此处因为是demo，默认开启
        mockEnable = true
        Console.log(tag: "HSMockParser", msg: "\(dict)")
        maxTimeUse = dict["maxTimeUse"] as? Int
        if !mockEnable {
            return
        }
        guard let data = dict["data"] as? [String: Any] else { return }
        let _: [()] = data.map { (key, value) in
            let config = config(for: value as! [String : Any])
            self.configDic.updateValue(config!, forKey: key)
        }
    }
    private func config(for dict: [String: Any]) -> HSMockConfigrationItem? {
        guard let mockEnable = dict["mockEnable"] as? Bool else { return nil }
        if !mockEnable {
            return nil
        }
        guard let fileArray = dict["mockFile"] as? [[String: Any]] else { return nil }
        var result: [HSMockConfigrationItem.HSMockConfigrationFile] = []
        for value in fileArray {
            if let fileName = value["fileName"] as? String, let percent = value["percent"] as? Int, percent > 0 {
                let config = HSMockConfigrationItem.HSMockConfigrationFile(fileName: fileName, percent: percent)
                result.append(config)
            }
        }
        if fileArray.count > 0 {
            let config = HSMockConfigrationItem(mockEnable: mockEnable, fileArray: result)
            return config
        }
        return nil
    }
    func hasMockData(for key: String) -> Bool {
        return configDic[key] != nil
    }
    func mockData(for key: String) -> String? {
        if !hasMockData(for: key) {
            return nil
        }
        guard let obj = configDic[key]?.fileArray else { return nil }
        var total: Int = 0
        for value in obj {
            total += value.percent ?? 0
        }
        
        let random = Int(arc4random()) % total
        var start: Int = 0, fileName: String?
        for value in obj {
            if random >= start && random < (start + (value.percent ?? 0)) {
                fileName = value.fileName
                break
            }
            start += value.percent ?? 0
        }
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: nil) else {
            fatalError("not found file path.")
        }
        guard let content = try? NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) else {
            fatalError("not read JSON")
        }
        return content as String
    }
}
