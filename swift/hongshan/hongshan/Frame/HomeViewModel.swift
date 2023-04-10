//
//  HomeViewModel.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/5.
//

import Foundation
import UIKit
import Combine

class HomeViewModel: ViewModel {
    @Published var dataArray: [HomeDataRequest.Response.HomeDataRequestData] = []
    @Published private(set) var images: [HomeDataRequest.Response.HomeDataRequestData: UIImage] = [:]
    @Published private var cancellable: Cancellable?
}

extension HomeViewModel {
    func refresh() {
        
    }
    func loadHomeData() {
        let assign = Subscribers.Assign(object: self, keyPath: \.dataArray)
        cancellable = assign
        let request = HomeDataRequest()
        Networking.default.fetch(from: request).map { result in
            result.data
        }
            .replaceError(with: [])
            .receive(on: OperationQueue.main)
            .receive(subscriber: assign)
        //        Networking.default.fetch(request) { [weak self] result in
        //            switch result {
        //            case .success(let success):
        //                guard let obj = success.data else { return }
        //                self?.dataArray = obj
        //                print(obj)
        //            case .failure(let failure):
        //                switch failure {
        //                case .HTTPSError(let error):
        //                    print(error)
        //                case .JSONTransfer(let error):
        //                    print(error)
        //                case .NoneYetData:
        //                    print("fffff")
        //                }
        //            }
        //        }
    }
    
    func loadImage(for app: HomeDataRequest.Response.HomeDataRequestData) {
        guard case .none = images[app] else {
            return
        }
        guard let url = URL(string: app.url) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.send(request: request)
            .map { UIImage(data: $0) }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .receive(subscriber: Subscribers.Sink<UIImage?, Never>(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] image in
                self?.images[app] = image
            }))
    }
}

extension HomeViewModel: ViewModelType {
    struct Input {
        var currentPage: Int
        var totalPage: Int
    }
    struct Output {
        let numberOfItems: Int
        let items: [HomeDataRequest.Response.HomeDataRequestData]
    }
    func transform() -> Output {
        let row = dataArray.count
        let output = Output(numberOfItems: row, items: dataArray)
        return output
    }
}
