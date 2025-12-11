//
//  HomeView.swift
//  Smth
//
//  首页视图，展示热门话题和版块选择器
//  Created by tony
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var browsingHistory: BrowsingHistoryStore
    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var navigationViewModel = HomeNavigationViewModel()
    @StateObject private var viewModel = NaviTopicListViewModel()
    @State private var selectedIndex: Int = 0
    @State private var showProfileView = false
    @State private var hasInitializedFirstNavigation = false
    
    private var currentNavigationType: String? {
        guard navigationViewModel.navigations.indices.contains(selectedIndex) else {
            return nil
        }
        return navigationViewModel.navigations[selectedIndex].type
    }
    
    private var isAlbumView: Bool {
        currentNavigationType == "album"
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.compactSpacing, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(viewModel.topics) { topic in
                        NavigationLink(value: topic) {
                            if isAlbumView {
                                AlbumTopicRowView(
                                    topic: topic,
                                    isVisited: browsingHistory.visitedTopicIDs.contains(topic.id)
                                )
                            } else {
                                TopicRowView(
                                    topic: topic,
                                    isVisited: browsingHistory.visitedTopicIDs.contains(topic.id)
                                )
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onAppear {
                            viewModel.loadNextPageIfNeeded(currentItem: topic)
                        }
                    }
                } header: {
                    NavigationSelector(
                        navigations: navigationViewModel.navigations,
                        selectedIndex: $selectedIndex
                    )
                }
            }
        }
        .smthScaffoldBackground()
        .tint(AppTheme.accentColor(for: colorScheme))
        .navigationDestination(for: Topic.self) { topic in
            TopicDetailView(topicID: topic.id)
        }
        .navigationDestination(for: SearchDestination.self) { destination in
            switch destination {
            case .search:
                SearchView()
            }
        }
        .toolbarTitleDisplayMode(.inlineLarge)
        .onAppear {
            Task {
                await navigationViewModel.loadNavigationsIfNeeded()
            }
        }
        .onChange(of: navigationViewModel.navigations) { _, newNavigations in
            // 当导航数据首次加载完成时，初始化第一个导航项
            if !newNavigations.isEmpty && !hasInitializedFirstNavigation {
                hasInitializedFirstNavigation = true
                let firstNavigation = newNavigations[0]
                Task {
                    await viewModel.switchNavigation(to: firstNavigation)
                }
            }
        }
        .onChange(of: selectedIndex) { _, newIndex in
            guard navigationViewModel.navigations.indices.contains(newIndex) else { return }
            let selectedNavigation = navigationViewModel.navigations[newIndex]
            Task {
                await viewModel.switchNavigation(to: selectedNavigation)
            }
        }
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: SearchDestination.search) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showProfileView = true
                } label: {
                    Image(systemName: "person.crop.circle")
                }
            }
        }
        .sheet(isPresented: $showProfileView) {
            NavigationStack {
                ProfileView()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
#endif
    }

}

private enum SearchDestination: Hashable {
    case search
}

#Preview {
    HomeView()
}
