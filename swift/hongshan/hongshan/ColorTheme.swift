//
//  ColorTheme.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/12.
//

import SwiftUI
enum Link: Hashable {
   case followers(Int)
   case following(Int)
}

struct ColorTheme: View {
    @State private var deviceName: String = ""
        @State private var isWifiEnabled: Bool = false
        @State private var autoJoinOption: Int = 1
        @State private var date = Date()
        
        var body: some View {
            NavigationStack {
                Form {

                    Section {
                        TextField("Name", text: $deviceName)
                        LabeledContent("iOS Version", value: "16.2")
                    } header: {
                        Text("About")
                    }.listRowBackground(Color.yellow)

                    Section {
                        Toggle("Wi-Fi", isOn: $isWifiEnabled)
                        Picker("Auto-Join Hotspot", selection: $autoJoinOption) {
                            ForEach(1..<7) { option in
                                Text("Row \(option.description)")
                            }
                        }

                    } header: {
                        Text("Internet")
                    }
                    
                    Section {
                        DatePicker("Date picker", selection: $date)
                    }
                    
                    Section {
                        Button("Reset All Content and Settings") {
                            // Reset logic
                        }
                    }
                }
                .foregroundColor(.brown)
                .tint(.pink)
                .background(Color.pink)

                .scrollContentBackground(.hidden)
                .navigationBarTitle("Settings")
            }
        }
}
