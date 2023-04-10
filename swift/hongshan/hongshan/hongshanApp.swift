//
//  HongShanApp.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/4.
//

import SwiftUI
import Combine

@main
struct HongShanApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                print("App is active")
            case .inactive:
                print("App is inactive")
            case .background:
                print("App is background")
            @unknown default:
                print("Oh - interesting: I received an unexpected new value.")
            }
        }
    }
    
}
