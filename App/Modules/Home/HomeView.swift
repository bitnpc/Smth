//
//  HomeView.swift
//  Smth
//
//  Created by 仝超 on 2025/11/12.
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
        .toolbarTitleDisplayMode(.inlineLarge)
        .onAppear {
            Task {
                await viewModel.loadInitialIfNeeded()
            }
        }
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    print("搜索")
                }) {
                    Image(systemName: "magnifyingglass.circle")
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

#Preview {
    HomeView()
}
