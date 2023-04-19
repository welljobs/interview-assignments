//
//  ViewController.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/12.
//

import UIKit

class ViewController: UIViewController {
    var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        button.addAction(UIAction(handler: { [weak self] (action) in
            guard let self else { return }
            self.didTapButton()
        }), for: .touchUpInside)
    }
    func didTapButton() {
        print(#file)
    }
    
    func kWeakestRows(_ mat: [[Int]], _ k: Int) -> [Int] {
        var result: [Int: Int] = [:]
        for (i, v1) in mat.enumerated() {
            print("第\(i)行：\(v1)")
            var total: Int = 0
            for (_, v2) in v1.enumerated() {
                //                print("第\(j)列：\(v2)")
                total += v2
            }
            result[total] = i
        }
        let sorted = result.sorted { d1, d2 -> Bool in
            if (d1.value != d2.value) {
                return d1.value < d2.value
            }
            return d1.key < d2.key
        }
        var value: [Int] = []
        for dict in sorted where dict.key < k {
            
        }
        //        var low: Int = 0, high: Int = sorted.count - 1
        //        while low < high {
        //            var mid = low + (low + high) >> 1
        //            if sorted[mid].value
        //        }
        
        print(value)
        return Array(value)
    }
    
    func letterCasePermutation(_ s: String) -> [String] {
        var m: Int = 0
        for ch in s {
            if ch.isNumber {
                continue
            }
            m += 1
        }
        var ans: [String] = []
        for mask in 0..<(1 << m) {
            print(mask)
            var str: String = ""
            var k: Int = m - 1
            for j in 0..<s.count {
                let char = s[s.index(s.startIndex, offsetBy: j)]
                if char.isLetter {
                    if ((mask >> k) & 1) == 1 {
                        str += char.uppercased()
                    } else {
                        str += char.lowercased()
                    }
                    k -= 1
                } else {
                    str += String(char)
                }
            }
            ans.append(str)
        }
        return ans
    }
    func letterCasePermutation1(_ s: String) -> [String] {
        guard !s.isEmpty else {
            return []
        }
        var result: [String] = []
        func dfs(_ res: inout [String], _ path: String, _ start: Int) {
            if s.count == path.count {
                res.append(path)
                return
            }
            
            var path = path
            for i in start..<s.count {
//                let c = s[s.index(s.startIndex, offsetBy: i)..<s.index(s.startIndex, offsetBy: i + 1)]
                let char = s[s.index(s.startIndex, offsetBy: i)]
                print(type(of: char))
                if char.isLowercase {
                    path += char.uppercased()
                    dfs(&res, path, i + 1)
                    path.removeLast()
                } else if char.isUppercase {
                    path += char.lowercased()
                    dfs(&res, path, i + 1)
                    path.removeLast()
                }
                path += String(char)
                dfs(&res, path, i + 1)
                path.removeLast()
            }
            
        }
        dfs(&result, "", 0)
        return result
    }
}
