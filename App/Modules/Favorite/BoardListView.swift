//
//  BoardListView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct BoardListView: View {
    let section: SMSection

    @StateObject private var viewModel: BoardListViewModel

    @MainActor
    init(section: SMSection, viewModel: BoardListViewModel? = nil) {
        self.section = section
        if let viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(wrappedValue: BoardListViewModel(sectionID: section.id))
        }
    }
    
    var body: some View {
        List {
            ForEach(viewModel.filteredBoards, id: \.id) { board in
                NavigationLink(value: board) {
                    HStack {
                        if board.type == 0 {
                            Text(board.title)
                            Text(board.name).font(.footnote).foregroundColor(.gray)
                        }else {
                            Text(board.title)
                            Text("目录").font(.footnote).foregroundColor(.blue).backgroundStyle(.blue)
                        }
                    }
                }
            }
        }
        .onAppear() {
            Task {
                await viewModel.loadBoardsIfNeeded()
            }
        }
        .listStyle(.plain)
        .navigationTitle(section.name)
        .navigationDestination(for: Board.self) { board in
            if (board.type == 0) {
                TopicListView(board: board)
            }else {
                let subBoardArray = viewModel.subBoards(for: board)
                SubBoardListView(boardName: board.title, boards: subBoardArray)
            }
        }
        .overlay {
            if viewModel.filteredBoards.isEmpty {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
