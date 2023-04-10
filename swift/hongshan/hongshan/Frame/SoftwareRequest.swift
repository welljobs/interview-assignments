//
//  SoftwareRequest.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/5.
//

import Foundation

struct SoftwareRequestResult: Codable {
    var resultCount: Int
    var results: [Software]
    
    struct Software: Codable, Equatable {
        var artworkUrl100: String?
        var artistName: String?
        var description: String?
        var releaseNotes: String?
        var trackId: Int?
        var trackName: String?
    }
}
