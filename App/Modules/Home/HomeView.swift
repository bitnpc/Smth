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

    private let boards: [Board] = Board.defaultBoard()

    @State private var selectedIndex: Int = 0
    @State private var showProfileView = false
    @StateObject private var viewModel = TopicListViewModel(boardID: Board.defaultBoard().first!.id)

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.verticalSpacing, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(viewModel.topics) { topic in
                        NavigationLink(value: topic) {
                            TopicRowView(
                                topic: topic,
                                isVisited: browsingHistory.visitedTopicIDs.contains(topic.id)
                            )
                            .onAppear {
                                viewModel.loadNextPageIfNeeded(currentItem: topic)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } header: {
                    BoardSelector(
                        boards: boards,
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
                await viewModel.loadInitialIfNeeded()
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
                Button(action: {
                    showProfileView = true
                }) {
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

    private var currentBoard: Board {
        boards[boards.indices.contains(selectedIndex) ? selectedIndex : boards.startIndex]
    }
}

private enum SearchDestination: Hashable {
    case search
}

#Preview {
    HomeView()
}
