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
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarItems()
            }
        })
        .navigationDestination(for: Topic.self) { topic in
            TopicDetailView(topicID: topic.id)
        }
        .onAppear {
            Task {
                await viewModel.loadInitialIfNeeded()
            }
        }
    }

    private var currentBoard: Board {
        boards[boards.indices.contains(selectedIndex) ? selectedIndex : boards.startIndex]
    }
    
    @ViewBuilder
    private func toolbarItems() -> some View {
        HStack {
            Button(action: {
                print("搜索")
            }) {
                Image(systemName: "magnifyingglass.circle")
            }
            Button(action: {
                print("我的")
            }) {
                Image(systemName: "person.crop.circle")
            }
        }
    }
}

#Preview {
    HomeView()
}
