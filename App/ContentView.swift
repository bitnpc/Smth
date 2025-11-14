//
//  ContentView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    @State private var selection: RootDestination? = .home

    var body: some View {
        Group {
            #if os(macOS)
            sidebarLayout
            #else
            if horizontalSizeClass == .compact {
                tabLayout
            } else {
                sidebarLayout
            }
            #endif
        }
        .smthScaffoldBackground()
        .tint(AppTheme.accentColor(for: colorScheme))
    }

    private var tabLayout: some View {
        TabView(selection: Binding(get: {
            selection ?? .home
        }, set: {
            selection = $0
        })) {
            NavigationStack {
                HomeView()
                    .navigationTitle("首页")
            }
            .tabItem {
                Label("首页", systemImage: "house")
            }
            .tag(RootDestination.home)

            NavigationStack {
                FavoritesView()
                    .navigationTitle("收藏")
            }
            .tabItem {
                Label("收藏", systemImage: "heart")
            }
            .tag(RootDestination.favorites)

            NavigationStack {
                MessagesView()
                    .navigationTitle("消息")
            }
            .tabItem {
                Label("消息", systemImage: "bubble.left.and.bubble.right")
            }
            .tag(RootDestination.messages)

            NavigationStack {
                ProfileView()
                    .navigationTitle("我的")
            }
            .tabItem {
                Label("我的", systemImage: "person.circle")
            }
            .tag(RootDestination.mine)
        }
        .background(Color.clear)
    }

    private var sidebarLayout: some View {
        NavigationSplitView {
            List(RootDestination.allCases, selection: $selection) { destination in
                Label(destination.title, systemImage: destination.iconName)
                    .tag(destination)
            }
            .listStyle(.sidebar)
            .navigationTitle("水木社区")
        } content: {
            EmptyView()
        } detail: {
            detailView(for: selection ?? .home)
        }
    }

    @ViewBuilder
    private func detailView(for destination: RootDestination) -> some View {
        switch destination {
        case .home:
            NavigationStack {
                HomeView()
            }
        case .favorites:
            NavigationStack {
                FavoritesView()
            }
        case .messages:
            NavigationStack {
                MessagesView()
            }
        case .mine:
            NavigationStack {
                ProfileView()
            }
        }
    }
}

private enum RootDestination: String, CaseIterable, Hashable, Identifiable {
    case home
    case favorites
    case messages
    case mine

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "首页"
        case .favorites: return "收藏"
        case .messages: return "消息"
        case .mine: return "我的"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house"
        case .favorites: return "heart"
        case .messages: return "bubble.left.and.bubble.right"
        case .mine: return "person.circle"
        }
    }
}
