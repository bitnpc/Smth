//
//  TopicListViewModel.swift
//  Smth
//
//  Created for the 2025 refactor.
//

import Foundation

@MainActor
final class TopicListViewModel: ObservableObject {
    @Published private(set) var topics: [Topic] = []
    @Published private(set) var isLoadingPage = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var errorMessage: String?

    private let repository: TopicRepositoryProtocol
    private let pageSize: Int
    private var paginationState = PaginationState<Topic>()
    private let boardID: String?

    init(
        repository: TopicRepositoryProtocol = AppContainer.shared.resolve(TopicRepositoryProtocol.self),
        boardID: String? = nil,
        pageSize: Int = 20
    ) {
        self.repository = repository
        self.boardID = boardID
        self.pageSize = pageSize
    }

    func loadInitialIfNeeded() async {
        if topics.isEmpty {
            await loadInitialPage()
        }
    }

    func refresh() async {
        await loadInitialPage(isRefreshing: true)
    }

    func loadNextPageIfNeeded(currentItem item: Topic?) {
        guard let item else { return }
        let thresholdIndex = topics.index(topics.endIndex, offsetBy: -5, limitedBy: topics.startIndex) ?? topics.startIndex
        if topics.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            Task {
                await loadNextPage()
            }
        }
    }

    func retry() async {
        await loadInitialPage()
    }

    private func loadInitialPage(isRefreshing: Bool = false) async {
        if isRefreshing {
            self.isRefreshing = true
        } else {
            isLoadingPage = true
        }
        paginationState.reset()
        topics = []
        errorMessage = nil
        defer {
            isLoadingPage = false
            self.isRefreshing = false
        }
        await loadPage()
    }

    private func loadNextPage() async {
        guard !isLoadingPage else { return }
        isLoadingPage = true
        defer { isLoadingPage = false }
        await loadPage()
    }

    private func loadPage() async {
        let originalState = paginationState
        guard let nextPage = paginationState.startLoadingNextPage() else { return }
        do {
            let newItems: [Topic]
            if let boardID {
                newItems = try await repository.fetchTopics(in: boardID, page: nextPage, pageSize: pageSize)
            } else {
                newItems = try await repository.fetchHotTopics(page: nextPage, pageSize: pageSize)
            }
            paginationState.completeLoading(with: newItems, pageSize: pageSize)
            topics = paginationState.items
        } catch {
            errorMessage = error.localizedDescription
            paginationState = originalState
            topics = originalState.items
        }
    }
}


