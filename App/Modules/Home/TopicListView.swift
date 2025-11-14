//
//  TopicListView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct TopicListView: View {
    let board: Board

    @EnvironmentObject private var browsingHistory: BrowsingHistoryStore
    @StateObject private var viewModel: TopicListViewModel

    @MainActor
    init(board: Board, viewModel: TopicListViewModel? = nil) {
        self.board = board
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
                    .simultaneousGesture(TapGesture().onEnded {
                        browsingHistory.record(topic)
                    })
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
