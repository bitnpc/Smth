//
//  BoardSelector.swift
//  Smth
//
//  Created by 仝超 on 2025/11/12.
//

import SwiftUI

struct BoardSelector: View {
    let boards: [Board]
    @Binding var selectedIndex: Int

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(boards.enumerated()), id: \.element.id) { index, board in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedIndex = index
                            }
                        } label: {
                            Text(board.title)
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedIndex == index ? Color.accentColor.opacity(0.2) : Color(.systemGray5))
                                .foregroundColor(selectedIndex == index ? Color.accentColor : .primary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .id(board.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(.thinMaterial)
            .onChange(of: selectedIndex) { newValue in
                guard boards.indices.contains(newValue) else { return }
                let board = boards[newValue]
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(board.id, anchor: .center)
                }
            }
        }
    }
}
