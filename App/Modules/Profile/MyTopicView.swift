//
//  MyTopicView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/30.
//

import SwiftUI

struct MyTopicView: View {

    @StateObject private var viewModel = MyTopicsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.articles, id: \.id) { article in
                NavigationLink(value: article) {
                    ArticleRowView(article: article)
                }
            }
            if viewModel.articles.isEmpty {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                } else {
                    Text("暂无文章")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear() {
            Task {
                await viewModel.loadArticlesIfNeeded()
            }
        }
        .listStyle(.plain)
        .navigationTitle("我的文章")
        .navigationDestination(for: Article.self) { article in
            TopicDetailView(topicID: article.topicId)
        }
    }
}
