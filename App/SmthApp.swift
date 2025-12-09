//
//  SmthApp.swift
//  Smth
//
//  应用程序入口，配置应用环境和依赖注入
//  Created by tony
//

import SwiftUI

@main
struct SmthApp: App {
    @StateObject private var browsingHistoryStore = BrowsingHistoryStore()
    @StateObject private var fontSettings = FontSettings()
    @StateObject private var layoutSettings = LayoutSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.container, AppContainer.shared)
                .environmentObject(LoginState.shared)
                .environmentObject(browsingHistoryStore)
                .environmentObject(fontSettings)
                .environmentObject(layoutSettings)
                .dynamicTypeSize(fontSettings.dynamicTypeSize)
        }
    }
}
