//
//  TopicListView.swift
//  Smth
//
//  话题列表页面视图，展示版块中的话题列表
//  Created by tony
//

import SwiftUI

struct TopicListView: View {
    let board: Board
    let onTopicSelected: ((Topic) -> Void)?

    @EnvironmentObject private var browsingHistory: BrowsingHistoryStore
    @StateObject private var viewModel: TopicListViewModel

    @MainActor
    init(board: Board, viewModel: TopicListViewModel? = nil, onTopicSelected: ((Topic) -> Void)? = nil) {
        self.board = board
        self.onTopicSelected = onTopicSelected
        if let viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(wrappedValue: TopicListViewModel(boardID: board.id))
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.verticalSpacing) {
                ForEach(viewModel.topics) { topic in
                    topicSelectionView(for: topic)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if viewModel.isLoadingPage {
                    ProgressView()
                        .padding(.vertical, 32)
                }
            }
            .padding(.vertical, AppTheme.verticalSpacing)
        }
        .smthScaffoldBackground()
        .overlay(alignment: .center) {
            if viewModel.topics.isEmpty && viewModel.isLoadingPage {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage, viewModel.topics.isEmpty {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Button("重试") {
                        Task {
                            await viewModel.retry()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .navigationTitle(board.title)
        .onAppear {
            Task {
                await viewModel.loadInitialIfNeeded()
            }
        }
    }
}

extension TopicListView {
    @ViewBuilder
    private func topicSelectionView(for topic: Topic) -> some View {
        if let onTopicSelected {
            Button {
                browsingHistory.record(topic)
                onTopicSelected(topic)
            } label: {
                topicRow(for: topic)
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(value: topic) {
                topicRow(for: topic)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
                browsingHistory.record(topic)
            })
        }
    }

    private func topicRow(for topic: Topic) -> some View {
        TopicRowView(
            topic: topic,
            isVisited: browsingHistory.visitedTopicIDs.contains(topic.id)
        )
        .onAppear {
            viewModel.loadNextPageIfNeeded(currentItem: topic)
        }
    }
}
