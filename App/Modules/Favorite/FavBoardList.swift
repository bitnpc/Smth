//
//  FavBoardList.swift
//  Smth
//
//  Created by 仝超 on 2025/11/13.
//

import SwiftUI

struct FavBoardList: View {
    private let gridColumns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    @ObservedObject private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            if viewModel.favBoards.isEmpty {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("暂无收藏")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(viewModel.favBoards) { favBoard in
                    LazyVGrid(columns: gridColumns) {
                        ForEach(favBoard.items, id: \.self) { favBoardItem in
                            NavigationLink(value: FavoriteRoute.favBoardItem(favBoardItem)) {
                                boardCard(for: favBoardItem)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                NavigationLink(value: FavoriteRoute.allSection) {
                    Image(systemName: "list.bullet.clipboard")
                    Text("全部版面")
                }
            }
        }
        .navigationTitle("收藏版面")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func boardCard(for item: FavBoardItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.bid.title)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(2)
            Text(item.bid.name)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 0.5)
        }
    }

    private var cardBackgroundColor: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(uiColor: .secondarySystemBackground)
        #endif
    }

    private var borderColor: Color {
        #if os(macOS)
        return Color(nsColor: .separatorColor).opacity(0.4)
        #else
        return Color(uiColor: .separator).opacity(0.3)
        #endif
    }
}

