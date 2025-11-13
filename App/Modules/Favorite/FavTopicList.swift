//
//  FavTopicList.swift
//  Smth
//
//  Created by 仝超 on 2025/11/13.
//

import SwiftUI

struct FavTopicList: View {
    @EnvironmentObject private var loginState: LoginState
    @ObservedObject private var viewModel: FavoritesViewModel
    @State private var showLoginView = false
    
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            if viewModel.favTopics.isEmpty {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("暂无收藏")
                        .foregroundStyle(.secondary)
                }
            } else {
                List(viewModel.favTopics) { topic in
                    NavigationLink(value: FavoriteRoute.favTopic(topic)) {
                        Text(topic.subject)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("收藏话题")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
