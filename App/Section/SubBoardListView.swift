//
//  SubBoardListView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct SubBoardListView: View {
    
    let boardName: String
    let boards: [Board]
    
    var body: some View {
        List {
            ForEach(boards, id: \.id) { board in
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
        .listStyle(.plain)
        .navigationTitle(boardName)
    }
}

