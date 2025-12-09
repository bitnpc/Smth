//
//  FavBoardList.swift
//  Smth
//
//  收藏版块列表组件，展示用户收藏的版块
//  Created by tony
//

import SwiftUI

struct FavBoardList: View {
    @Environment(\.colorScheme) private var colorScheme

    private let gridColumns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: AppTheme.compactSpacing),
        count: 2
    )

    @ObservedObject private var viewModel: FavoritesViewModel
    private let onBoardSelected: ((FavBoardItem) -> Void)?
    
    init(viewModel: FavoritesViewModel, onBoardSelected: ((FavBoardItem) -> Void)? = nil) {
        self.viewModel = viewModel
        self.onBoardSelected = onBoardSelected
    }
    
    var body: some View {
        VStack(spacing: AppTheme.verticalSpacing) {
            if viewModel.favBoards.isEmpty {
                emptyView()
            } else {
                ForEach(viewModel.favBoards) { favBoard in
                    VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
                        Text(favBoard.name)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundStyle(.primary)

                        LazyVGrid(columns: gridColumns, spacing: AppTheme.compactSpacing) {
                            ForEach(favBoard.items, id: \.self) { favBoardItem in
                                if let onBoardSelected {
                                    Button {
                                        onBoardSelected(favBoardItem)
                                    } label: {
                                        boardCard(for: favBoardItem)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    NavigationLink(value: FavoriteRoute.favBoardItem(favBoardItem)) {
                                        boardCard(for: favBoardItem)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.vertical, AppTheme.compactSpacing)
                    .padding(.horizontal, AppTheme.verticalSpacing)
                    .smthSurfaceBackground()
                }

                NavigationLink(value: FavoriteRoute.allSection) {
                    HStack(spacing: 12) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 20, weight: .semibold))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("全部版面")
                                .font(.system(.headline, design: .rounded))
                            Text("探索全部分类，快速定位喜爱的社区。")
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 22)
                    .padding(.horizontal, AppTheme.verticalSpacing)
                    .smthSurfaceBackground(subdued: true)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, AppTheme.verticalSpacing)
    }

    @ViewBuilder
    private func boardCard(for item: FavBoardItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.bid.title)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
            Text(item.bid.name)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                .fill(AppTheme.surfaceBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                .stroke(AppTheme.borderColor(for: colorScheme), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func emptyView() -> some View {
        if let errorMessage = viewModel.errorMessage {
            VStack(spacing: 12) {
                Text(errorMessage)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("重试") {
                    Task {
                        await viewModel.loadFavoriteBoards()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 64)
            .smthSurfaceBackground()
        } else if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 64)
        } else {
            VStack(spacing: 10) {
                Image(systemName: "star")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(AppTheme.accentColor(for: colorScheme))
                Text("暂无收藏版面")
                    .font(.system(.headline, design: .rounded))
                Text("收藏你常去的版面，首页快速进入。")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 64)
            .smthSurfaceBackground(subdued: true)
        }
    }
}

