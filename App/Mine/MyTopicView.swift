//
//  MyTopicView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/30.
//

import SwiftUI

struct MyTopicView: View {

    @StateObject var dataSource = TopicDataSource()
    
    var body: some View {
        List {
            ForEach(dataSource.myTopics, id: \.id) { article in
                NavigationLink(value: article) {
                    ArticleRowView(article: article)
                }
            }
        }
        .onAppear() {
            Task {
                await dataSource.fetchMyTopic()
            }
        }
        .listStyle(.plain)
        .navigationTitle("我的文章")
        .navigationDestination(for: Article.self) { article in
            TopicDetailView(topicID: article.topicId)
        }
    }
}
