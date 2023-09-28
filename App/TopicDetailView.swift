//
//  TopicDetailView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI

struct TopicDetailView: View {
    var topic: Topic
    @StateObject var dataSource = TopicDetailDataSource()
    
    var body: some View {
        List {
            TopicContentView(article: dataSource.articles.first)
            ForEach(dataSource.articles.dropFirst(), id: \.id) { article in
                Text("\(article.content)")
            }
        }
        .onAppear() {
            Task {
                await dataSource.fetchArticles(topicID: topic.id, page: 0, sortType: .Defatul)
            }
        }
        .listStyle(.plain)
        .navigationTitle(dataSource.board?.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}


