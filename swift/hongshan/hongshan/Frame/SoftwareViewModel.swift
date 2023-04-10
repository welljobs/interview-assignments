//
//  SoftwareViewModel.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/5.
//

import Foundation

final class SoftwareViewModel: ObservableObject {
    @Published var result: [SoftwareRequestResult.Software] = []
    @Published var currentArray: [SoftwareRequestResult.Software] = []
    
    @Published var currentPage: Int = 50
    
    // 下拉刷新, 上拉加载
    @Published private(set) var isReloadData: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var isLoadingMore: Bool = false

    @MainActor
    func loadSoftware() async throws {
        let URLString = "https://itunes.apple.com/search?entity=software&limit=\(currentPage)&term=chat"
        isReloadData = true
        defer { isReloadData = false }
        do {
            guard let url = URL(string: URLString) else {
                throw SoftwareError.wrongURL
            }
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let hRes = response as? HTTPURLResponse, (200...300) ~= hRes.statusCode else {
                throw SoftwareError.statusCode
            }
            do {
                let soft = try JSONDecoder().decode(SoftwareRequestResult.self, from: data)
                self.result = soft.results
                self.currentArray = Array(soft.results[0..<5])
            } catch {
                throw SoftwareError.custom(error: error)
            }
        } catch {
            throw SoftwareError.custom(error: error)
        }
    }
    @MainActor
    func reload() async throws {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentPage = 5
            if (0...self.result.count).contains(self.currentPage) {
                self.currentArray = Array(self.result[0..<self.currentPage])
            }
        }
    }
    @MainActor
    func loadMore() async throws {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentPage += 5
            if (0...self.result.count).contains(self.currentPage) {
                self.currentArray = Array(self.result[0..<self.currentPage])
            } else {
                self.currentPage = self.result.count
            }
        }
    }
}
extension SoftwareViewModel {
    enum SoftwareError: LocalizedError {
        case custom(error: Error)
        case wrongURL
        case decode
        case statusCode
        
        var errorDescription: String? {
            switch self {
            case .wrongURL:
                return "Wrong URL"
            case .decode:
                return "Failed to decode"
            case .custom(let error):
                return error.localizedDescription
            case .statusCode:
                return "Invalid status code"
            }
        }
    }
}
