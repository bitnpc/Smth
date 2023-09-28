//
//  HotTopicView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI

struct HotTopicView: View {
    
    @StateObject var dataSource = TopicDataSource()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataSource.topics, id: \.id) { topic in
                    NavigationLink(value: topic) {
                        TopicRowView(topic: topic)
                    }
                }
            }
            .onAppear() {
                Task {
                    await dataSource.fetchTopics()
                }
            }
            .listStyle(.plain)
            .navigationTitle("热门")
            .navigationDestination(for: Topic.self) { topic in
                TopicDetailView(topic: topic)
            }
        }
    }
}

struct HotTopicView_Previews: PreviewProvider {
    static var previews: some View {
        HotTopicView()
    }
}
