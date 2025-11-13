//
//  TopicDetailView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI

struct TopicDetailView: View {
    let topicID: String
    @StateObject private var viewModel: TopicDetailViewModel

    @MainActor
    init(topicID: String, viewModel: TopicDetailViewModel? = nil) {
        self.topicID = topicID
        if let viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(wrappedValue: TopicDetailViewModel(topicID: topicID))
        }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                    Button("重试") {
                        Task {
                            await viewModel.load(page: 0)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else if let firstArticle = viewModel.articles.first {
                List {
                    TopicContentRowView(article: firstArticle)
                    ForEach(viewModel.articles.dropFirst(), id: \.id) { article in
                        ArticleRowView(article: article)
                    }
                }
                .listStyle(.plain)
            } else {
                Text("暂无内容")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(viewModel.board?.title ?? "")
        .toolbar(.hidden, for: .tabBar)
        .applyNavigationDisplayMode()
        .onAppear {
            Task {
                await viewModel.loadIfNeeded()
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func applyNavigationDisplayMode() -> some View {
        #if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}


