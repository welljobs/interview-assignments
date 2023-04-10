//
//  HomeStackView.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/4.
//

import SwiftUI

struct HomeStackView: View {
    @StateObject private var viewModel = SoftwareViewModel()
    @State private var error: SoftwareViewModel.SoftwareError?
    @State private var hasError: Bool = false
    
    @State private var headerRefreshing: Bool = false
    @State private var footerRefreshing: Bool = false
    @State private var hasMore: Bool = false
    
    @State private var selection: String?
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.isReloadData {
                case true:
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
                case false:
                    ScrollView{
                        VStack(spacing: 10){
                            ForEach(viewModel.currentArray, id: \.trackId) { thisItem in
                                // Item View
                                HomeViewRow(app: thisItem)
                                //设置每个卡片视图高度.
                                    .frame(height: 100)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .enableRefresh()
                    .overlay(Group {
                        if viewModel.result.count == 0 {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
                        } else {
                            EmptyView()
                        }
                    })
                }
                
            }
            .navigationTitle("App")
            .background(Color.black.opacity(0.06).edgesIgnoringSafeArea(.all))
        }
        .alert(error?.errorDescription ?? "Error request", isPresented: $hasError, actions: {
            Button {
                self.loadData()
            } label: {
                Text("Retry")
            }
        }, message: {
            
        })
        .onAppear {
            Console.log(tag: "ContentView", msg: "onAppear")
            self.loadData()
        }
        .onDisappear {
            Console.log(tag: "ContentView", msg: "onDisappear")
        }
    }
}
extension HomeStackView {
    func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            Task {
                do {
                    try await self.viewModel.loadSoftware()
                } catch {
                    guard let wrong = error as? SoftwareViewModel.SoftwareError else {
                        return
                    }
                    self.hasError = true
                    self.error = wrong
                }
            }
        }
    }
    func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.headerRefreshing = false
            self.hasMore = false
            Task {
                try await self.viewModel.reload()
            }
        }
    }
    func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.footerRefreshing = false
            Task {
                try await self.viewModel.loadMore()
                self.hasMore = self.viewModel.result.count >= 50
                Console.log(tag: "Refresh", msg: "currentPage: \(self.viewModel.currentPage)")
                Console.log(tag: "Refresh", msg: "totalNumber: \(self.viewModel.result.count)")
                Console.log(tag: "Refresh", msg: "hasMore: \(self.hasMore) footerRefreshing: \(self.footerRefreshing)")
            }
        }
    }
}

struct HomeStackView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStackView()
    }
}

