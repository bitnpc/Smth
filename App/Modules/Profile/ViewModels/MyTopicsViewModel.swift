//
//  MyTopicsViewModel.swift
//  Smth
//
//  我的话题视图模型，管理用户发布的话题列表
//  Created by tony
//

import Foundation

@MainActor
final class MyTopicsViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: TopicRepositoryProtocol

    init(repository: TopicRepositoryProtocol = AppContainer.shared.resolve(TopicRepositoryProtocol.self)) {
        self.repository = repository
    }

    func loadArticlesIfNeeded() async {
        guard articles.isEmpty else { return }
        await loadArticles()
    }

    func loadArticles(page: Int = 1) async {
        isLoading = true
        errorMessage = nil
        do {
            articles = try await repository.fetchMyTopics(page: page)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
