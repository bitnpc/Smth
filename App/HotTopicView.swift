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
    
    @State private var isRefresh = false
    @State private var isLoading = false

    @State private var page = 1
    
    var body: some View {
        NavigationStack {
            RefreshableListView(items: dataSource.topics, isRefreshing: isRefresh, onRefresh: {
                Task {
                    await dataSource.fetchTopics(page: 1)
                }
            }, isLoading: isLoading, loadMore: {
                page = page + 1
                Task {
                    await dataSource.fetchTopics(page: page)
                }
            }) { topic in
                NavigationLink(value: topic) {
                    TopicRowView(topic: topic)
                }
            }
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
