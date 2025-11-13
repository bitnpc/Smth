//
//  TopicListView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct TopicListView: View {
    let board: Board
    private let onScroll: ((CGFloat) -> Void)?
    private let coordinateSpaceID: String

    @EnvironmentObject private var browsingHistory: BrowsingHistoryStore
    @StateObject private var viewModel: TopicListViewModel

    @MainActor
    init(board: Board, viewModel: TopicListViewModel? = nil, onScroll: ((CGFloat) -> Void)? = nil) {
        self.board = board
        self.onScroll = onScroll
        self.coordinateSpaceID = "topic-list-\(board.id)"
        if let viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(wrappedValue: TopicListViewModel(boardID: board.id))
        }
    }

    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named(coordinateSpaceID)).minY)
            }
            .frame(height: 0)

            LazyVStack(spacing: 12) {
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
                        .padding(.vertical, 24)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .coordinateSpace(name: coordinateSpaceID)
        .background(listBackgroundColor)
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            guard let onScroll else { return }
            DispatchQueue.main.async {
                onScroll(value)
            }
        }
        .overlay(alignment: .center) {
            if viewModel.topics.isEmpty && viewModel.isLoadingPage {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage, viewModel.topics.isEmpty {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
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
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.loadInitialIfNeeded()
            }
        }
    }

    private var listBackgroundColor: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(uiColor: .systemGroupedBackground)
        #endif
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

