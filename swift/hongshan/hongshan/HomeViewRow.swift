//
//  HomeViewRow.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/10.
//

import SwiftUI

struct HomeViewRow: View {
    @State var app: SoftwareRequestResult.Software
    @State var reloadTrigger: Bool = false
    @State var status: Status = .loading
    
    @State var isFollowed: Bool = false
    
    var body: some View {
        HStack{
            Group {
                switch status {
                case .loading:
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
                case .image(let image):
                    image
                        .resizable()
                        .cornerRadius(10)
                        .aspectRatio(contentMode: .fit)
                case .error:
                    Rectangle()
                        .fill(.secondary)
                        .overlay(Text("Failed to load image"))
                }
            }
            .padding(15)
            .frame(width: 80, height: 80)
            
            VStack(alignment: .leading) {
                Text(app.trackName ?? "")
                    .fontWeight(.medium)
                    .padding(.top, 10)
                Text(app.description ?? "")
                    .fontWeight(.regular)
                    .padding(.bottom, 10)
            }
            .padding(.leading, -12)
            .frame(maxWidth: 1000, alignment: .leading)
            FavoriteButton {
                if isFollowed {
                    Image("FF0000_favorite_selected").padding(.trailing, 10)
                } else {
                    Image("8a8a8a_favorite_unselected").padding(.trailing, 10)
                }
            } didTapped: {
                isFollowed = !isFollowed
            }
            .padding(.horizontal,5)
            Spacer(minLength: 0)
        }
        .background(Color.white.shadow(color: Color.black.opacity(0.12), radius: 5, x: 0, y: 4))
        .cornerRadius(15)
        .task(id: reloadTrigger) {
            do {
                var bytes = [UInt8]()
                guard let url = URL(string: app.artworkUrl100 ?? "") else { return }
                for try await byte in url.resourceBytes {
                    bytes.append(byte)
                }
                if let uiImage = UIImage(data: Data(bytes)) {
                    let image = Image(uiImage: uiImage)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        status = .image(image)
                    })
                } else {
                    status = .error
                }
            } catch {
                
            }
        }
    }
    enum Status: Equatable {
        case loading
        case image(Image)
        case error
        
        var loading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }
    }
}
