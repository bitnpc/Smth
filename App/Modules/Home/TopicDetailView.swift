//
//  TopicDetailView.swift
//  Smth
//
//  话题详情页面视图，展示话题的所有回复文章
//  Created by tony
//

import SwiftUI

struct TopicDetailView: View {
    @Environment(\.colorScheme) private var colorScheme

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
                VStack(spacing: 16) {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("重试") {
                        Task {
                            await viewModel.load(page: 0)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if let firstArticle = viewModel.articles.first {
                listView(with: firstArticle)
            } else {
                Text("暂无内容")
                    .foregroundStyle(.secondary)
            }
        }
        .smthScaffoldBackground()
        .tint(AppTheme.accentColor(for: colorScheme))
        .navigationTitle(viewModel.board?.title ?? "")
        .applyNavigationDisplayMode()
        .onAppear {
            Task {
                await viewModel.loadIfNeeded()
            }
        }
    }

    @ViewBuilder
    private func listView(with firstArticle: Article) -> some View {
        List {
            TopicContentRowView(article: firstArticle)
                .listRowInsets(.init(top: 0, leading: 0, bottom: AppTheme.compactSpacing, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            ForEach(viewModel.articles.dropFirst(), id: \.id) { article in
                ArticleRowView(article: article)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: AppTheme.compactSpacing, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 10)
        .modifier(HideListBackgroundModifier())
    }
}

private struct HideListBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
        } else {
            content
        }
        #else
        content
        #endif
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
