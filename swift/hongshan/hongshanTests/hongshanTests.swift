//
//  HongShanTests.swift
//  HongShanTests
//
//  Created by Jobs Azeroth on 2023/4/4.
//

import XCTest
@testable import HongShan

final class HongShanTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testHasMockData() throws {
        Console.log(tag: "MockTest", msg: "读取本地Mock配置文件")
        let result = HSMockManager.default.hasMockData(for: "HomeDataRequest")
        XCTAssertEqual(result, true)
    }
    func testMockJSONData() throws {
        Console.log(tag: "MockTest", msg: "读取本地首页收据")
        let key = "HomeDataRequest"
        guard let filePath = Bundle.main.path(forResource: key, ofType: "json") else {
            fatalError("not found file path.")
        }
        guard let content = try? NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String else {
            fatalError("not read JSON")
        }
        
        if HSMockManager.default.hasMockData(for: key) {
            let duration = HSMockManager.default.requestDuration ?? 0
            let deadline = TimeInterval(duration)
            DispatchQueue.global().asyncAfter(deadline: .now() + deadline) {
                guard let json = HSMockManager.default.mockData(for: key) else { return }
                XCTAssertEqual(json, content, key)
            }
        }
    }
    func testAsyncRequest() async throws {
        Task {
            do {
                guard let json = try await Networking.default.mockData(for: "HomeDataRequest") else { return }
                XCTAssertNotNil(json)
            } catch {
                XCTAssertThrowsError(error)
            }
        }
    }
}
