//
//  SmthApp.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/24.
//

import SwiftUI

@main
struct SmthApp: App {
    @StateObject private var browsingHistoryStore = BrowsingHistoryStore()
    @StateObject private var fontSettings = FontSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.container, AppContainer.shared)
                .environmentObject(LoginState.shared)
                .environmentObject(browsingHistoryStore)
                .environmentObject(fontSettings)
                .dynamicTypeSize(fontSettings.dynamicTypeSize)
        }
    }
}
