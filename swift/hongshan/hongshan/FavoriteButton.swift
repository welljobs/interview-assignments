//
//  FavoriteButton.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/10.
//

import SwiftUI

struct FavoriteButton<Label: View>: View {
    @ViewBuilder var label: () -> Label
    var didTapped: () async -> Void
    @State private var isRunning = false // 避免连续点击造成重复执行事件
    
    var body: some View {
        Button {
            isRunning = true
            Task {
                await didTapped()
                isRunning = false
            }
        } label: {
            label().opacity(isRunning == true ? 0 : 1)
            if isRunning == true {
                ProgressView()
            }
        }
        .disabled(isRunning)
        
    }
}
