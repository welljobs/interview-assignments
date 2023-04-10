//
//  ContentView.swift
//  HongShan
//
//  Created by Jobs Azeroth on 2023/4/4.
//

import SwiftUI


// 下拉刷新延时时间
public let refreshTime: Double = 0.4
// 加载更多延时时间
public let loadMoreTime: Double = 0.3

// 默认的列表条目内边距
public let defaultPadding: EdgeInsets = EdgeInsets(top: 2.5, leading: 15, bottom: 2.5, trailing: 15)

struct ContentView: View {
    init() {
        // 设置状态栏颜色
        let tabbarAppearance = UITabBarAppearance()
        tabbarAppearance.configureWithOpaqueBackground()
        tabbarAppearance.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 247/255, alpha: 1)
        UITabBar.appearance().standardAppearance = tabbarAppearance
        
        // 设置导航栏颜色
        let navibarAppearance = UINavigationBarAppearance()
        navibarAppearance.configureWithOpaqueBackground()
        navibarAppearance.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 247/255, alpha: 1)
        UINavigationBar.appearance().standardAppearance = navibarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navibarAppearance
    }

    var body: some View {
        HomeStackView()
    }
}
