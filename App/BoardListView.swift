//
//  BoardListView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct BoardListView: View {
    let section: Section
    
    @StateObject var dataSource = BoardDataSource()
    
    var body: some View {
        List {
            ForEach(dataSource.boards, id: \.id) { board in
//                    NavigationLink(value: section) {
                    Text(board.title)
//                    }
            }
        }
        .onAppear() {
            Task {
                await dataSource.fetchBoards(sectionID: section.id)
            }
        }
        .listStyle(.plain)
        .navigationTitle(section.name)
//            .navigationDestination(for: Section.self) { section in
//                TopicDetailView(topic: topic)
//            }
    }
}
