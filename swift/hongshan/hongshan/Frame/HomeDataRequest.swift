//
//  HomeDataRequest.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/4.
//

import Foundation


struct HomeDataRequest: HTTPRequest {
    typealias Input = Parameter
    typealias Output = Response

    let path: String = "HomeDataRequest"
    var params: Parameter = Parameter()

    struct Parameter: Codable {

    }
    struct Response: HTTPSResponse {
                
        var message: String?
        
        var success: Int?
        
        var total: Int?
        
        var pageSize: Int?
        
        var pageNo: Int?
        
        var data: [HomeDataRequestData]
    }
}

extension HomeDataRequest.Response {
    struct HomeDataRequestData: Codable, Hashable, Identifiable {
        var id: Int
        var title: String
        var url: String
        var favorite: Bool
        var descript: String
    }
}

let homeData = Networking.default.load(HomeDataRequest())
