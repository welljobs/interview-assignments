//
//  ColorDetail.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/12.
//

import SwiftUI

struct ColorDetail: View {
//    @Binding var path: [Color]
    @Binding var isShowing: Bool
//    let color: Color
    var body: some View {
        VStack {
//            color.ignoresSafeArea()
            Button("Dismiss") {
//                path.removeLast()
                isShowing = false
            }
        }
    }
}
