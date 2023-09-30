//
//  BoardListView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct BoardListView: View {
    let section: SMSection
    
    @StateObject var dataSource = BoardDataSource()
    
    var body: some View {
        List {
            ForEach(dataSource.boards, id: \.id) { board in
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
                await dataSource.fetchBoards(sectionID: section.id)
            }
        }
        .listStyle(.plain)
        .navigationTitle(section.name)
        .navigationDestination(for: Board.self) { board in
            if (board.type == 0) {
                TopicListView(board: board)
            }else {
                let subBoardArray = dataSource.allboards.filter { subBoard in
                    subBoard.groupId == board.id
                }
                SubBoardListView(boardName: board.title, boards: subBoardArray)
            }
        }
    }
}
