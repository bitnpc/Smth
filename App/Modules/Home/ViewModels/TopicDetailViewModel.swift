//
//  TopicDetailViewModel.swift
//  Smth
//
//  Handles article list loading for a specific topic.
//

import Foundation

@MainActor
final class TopicDetailViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var board: Board?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: TopicRepositoryProtocol
    private let topicID: String
    private let sortType: SortType

    init(
        topicID: String,
        sortType: SortType = .default,
        repository: TopicRepositoryProtocol = AppContainer.shared.resolve(TopicRepositoryProtocol.self)
    ) {
        self.topicID = topicID
        self.sortType = sortType
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard articles.isEmpty else { return }
        await load(page: 0)
    }

    func load(page: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let detail = try await repository.fetchTopicDetail(topicID: topicID, page: page, sortType: sortType)
            articles = detail.articles
            board = detail.board
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}


