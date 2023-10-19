//
//  TopicDetailView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI

struct TopicDetailView: View {
    let topicID: String
    @StateObject var dataSource = TopicDetailDataSource()
    
    var body: some View {
        if dataSource.articles.first == nil {
            Text("Loading")
            .onAppear() {
                dataSource.fetchArticles(topicID: topicID, page: 0, sortType: .Defatul)
            }
        }else {
            List {
                TopicContentRowView(article: dataSource.articles.first!)
                ForEach(dataSource.articles.dropFirst(), id: \.id) { article in
                    ArticleRowView(article: article)
                }
            }
            .listStyle(.plain)
            .navigationTitle(dataSource.board?.title ?? "")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


