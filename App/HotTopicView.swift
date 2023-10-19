//
//  HotTopicView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI

struct HotTopicView: View {
    
    @StateObject var dataSource = TopicDataSource()
    @State private var showPublishView = false
    
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
            .refreshable(action: {
                Task {
                    await dataSource.fetchTopics()
                }
            })
            .listStyle(.plain)
            .navigationTitle("话题")
            .navigationDestination(for: Topic.self) { topic in
                TopicDetailView(topicID: topic.id)
            }
            .toolbar {
                Button {
                    showPublishView = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }.sheet(isPresented: $showPublishView) {
                    PublishView()
                }
            }
        }
    }
}
