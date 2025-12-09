//
//  FavTopicList.swift
//  Smth
//
//  收藏话题列表组件，展示用户收藏的话题
//  Created by tony
//

import SwiftUI

struct FavTopicList: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var viewModel: FavoritesViewModel
    private let onTopicSelected: ((Topic) -> Void)?
    
    init(viewModel: FavoritesViewModel, onTopicSelected: ((Topic) -> Void)? = nil) {
        self.viewModel = viewModel
        self.onTopicSelected = onTopicSelected
    }
    
    var body: some View {
        VStack(spacing: AppTheme.verticalSpacing) {
            if viewModel.favTopics.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: AppTheme.verticalSpacing) {
                    ForEach(Array(viewModel.favTopics.enumerated()), id: \.element.id) { index, topic in
                        let hasNewReply = viewModel.hasNewReply(for: topic.id)
                        if let onTopicSelected {
                            Button {
                                onTopicSelected(topic)
                            } label: {
                                FavTopicRowView(topic: topic, hasNewReply: hasNewReply)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                // 当滚动到倒数第5个时加载下一页
                                if index == viewModel.favTopics.count - 5 {
                                    Task {
                                        await viewModel.loadNextFavoriteTopicsPage()
                                    }
                                }
                            }
                        } else {
                            NavigationLink(value: FavoriteRoute.favTopic(topic)) {
                                FavTopicRowView(topic: topic, hasNewReply: hasNewReply)
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                // 当滚动到倒数第5个时加载下一页
                                if index == viewModel.favTopics.count - 5 {
                                    Task {
                                        await viewModel.loadNextFavoriteTopicsPage()
                                    }
                                }
                            }
                        }
                    }
                    
                    if viewModel.isLoadingPage {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.vertical, AppTheme.compactSpacing)
            }
        }
        .padding(.vertical, AppTheme.verticalSpacing)
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else if viewModel.isLoading {
                ProgressView()
            } else {
                Image(systemName: "bookmark.slash")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(AppTheme.accentColor(for: colorScheme))
                Text("暂无收藏话题")
                    .font(.system(.headline, design: .rounded))
                Text("收藏后即可在此快速查看最新回复。")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 56)
        .padding(.horizontal, 28)
        .smthSurfaceBackground(subdued: true)
    }
}

// 自定义的 FavTopic Row View，支持显示新回复标识
struct FavTopicRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let topic: Topic
    let hasNewReply: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                TopicRowView(topic: topic)
                
                if hasNewReply {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.accentColor(for: colorScheme))
                            .frame(width: 8, height: 8)
                            .offset(x: -4, y: 4)
                        Spacer()
                    }
                    .frame(width: 8)
                }
            }
        }
    }
}
