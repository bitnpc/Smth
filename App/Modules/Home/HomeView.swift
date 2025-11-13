//
//  HomeView.swift
//  Smth
//
//  Created by 仝超 on 2025/11/12.
//

import SwiftUI

struct HomeView: View {
    private let boards: [Board] = Board.defaultBoard()

    @State private var selectedIndex: Int = 0
    @State private var headerHiddenStates: [String: Bool] = [:]

    var body: some View {
        VStack(spacing: 0) {
            if !isHeaderHidden(for: currentBoard.id) {
                BoardSelector(
                    boards: boards,
                    selectedIndex: $selectedIndex
                )
                .zIndex(1)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            TabView(selection: $selectedIndex) {
                ForEach(Array(boards.enumerated()), id: \.element.id) { index, board in
                    TopicListView(board: board) { offset in
                        updateHeaderHidden(for: board.id, with: offset)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationDestination(for: Topic.self) { topic in
            TopicDetailView(topicID: topic.id)
        }
        .animation(.easeInOut(duration: 0.2), value: isHeaderHidden(for: currentBoard.id))
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onAppear {
            preloadBoardStatesIfNeeded()
        }
    }

    private var currentBoard: Board {
        boards[boards.indices.contains(selectedIndex) ? selectedIndex : boards.startIndex]
    }

    private func preloadBoardStatesIfNeeded() {
        boards.forEach { board in
            if headerHiddenStates[board.id] == nil {
                headerHiddenStates[board.id] = false
            }
        }
    }

    private func isHeaderHidden(for boardID: String) -> Bool {
        headerHiddenStates[boardID] ?? false
    }

    private func updateHeaderHidden(for id: String, with offset: CGFloat) {
        let shouldHide: Bool
        if offset < -40 {
            shouldHide = true
        } else if offset > -5 {
            shouldHide = false
        } else {
            shouldHide = headerHiddenStates[id] ?? false
        }

        if headerHiddenStates[id] != shouldHide {
            headerHiddenStates[id] = shouldHide
        }
    }
}

#Preview {
    HomeView()
}
