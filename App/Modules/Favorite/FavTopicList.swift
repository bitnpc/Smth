//
//  FavTopicList.swift
//  Smth
//
//  Created by 仝超 on 2025/11/13.
//

import SwiftUI

struct FavTopicList: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: AppTheme.verticalSpacing) {
            if viewModel.favTopics.isEmpty {
                emptyState
            } else {
//                LazyVStack(spacing: AppTheme.verticalSpacing) {
                    ForEach(viewModel.favTopics) { topic in
                        NavigationLink(value: FavoriteRoute.favTopic(topic)) {
                            TopicRowView(topic: topic)
                        }
                        .buttonStyle(.plain)
                    }
//                }
//                .padding(.vertical, AppTheme.compactSpacing)
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
