//
//  TopicListView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct TopicListView: View {
    
    let board: Board
    
    @StateObject var dataSource = TopicDataSource()
    
    var body: some View {
        List {
            ForEach(dataSource.topics, id: \.id) { topic in
                NavigationLink(value: topic) {
                    TopicRowView(topic: topic)
                }
            }
        }
        .onAppear() {
            Task {
                await dataSource.fetchTopicInBoard(boardID: board.id)
            }
        }
        .listStyle(.plain)
        .navigationTitle(board.title)
        .navigationDestination(for: Topic.self) { topic in
            TopicDetailView(topic: topic)
        }
    }
}
