//
//  HotTopicView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI

struct HotTopicView: View {
    @EnvironmentObject private var browsingHistory: BrowsingHistoryStore
    @StateObject private var viewModel: TopicListViewModel
    @State private var showPublishView = false

    @MainActor
    init(viewModel: TopicListViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? TopicListViewModel())
    }

    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage = viewModel.errorMessage, viewModel.topics.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.orange)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("刷新重试") {
                            Task {
                                await viewModel.retry()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal, 24)
                } else {
                    List {
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
                            .simultaneousGesture(TapGesture().onEnded {
                                browsingHistory.record(topic)
                            })
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                            .listRowBackground(Color.clear)
                        }
                        if viewModel.isLoadingPage {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color(uiColor: .systemGroupedBackground))
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("热门话题")
//            .navigationDestination(for: Topic.self) { topic in
//                TopicDetailView(topicID: topic.id)
//            }
            .toolbar {
                Button {
                    showPublishView = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .sheet(isPresented: $showPublishView) {
                    PublishView()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadInitialIfNeeded()
            }
        }
    }
}

