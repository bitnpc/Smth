//
//  NaviTopicListViewModel.swift
//  Smth
//
//  Created by tony on 2025/12/11.
//

import Foundation

@MainActor
final class NaviTopicListViewModel: ObservableObject {
    @Published private(set) var topics: [Topic] = []
    @Published private(set) var isLoadingPage = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var errorMessage: String?

    private let repository: TopicRepositoryProtocol
    private let pageSize: Int
    private var paginationState = PaginationState<Topic>()
    private var navigation: Navigation?

    init(
        repository: TopicRepositoryProtocol = AppContainer.shared.resolve(TopicRepositoryProtocol.self),
        navigation: Navigation? = nil,
        pageSize: Int = 20
    ) {
        self.repository = repository
        self.navigation = navigation
        self.pageSize = pageSize
    }
    
    func switchNavigation(to newNavigation: Navigation) async {
        guard newNavigation.id != navigation?.id else { return }
        navigation = newNavigation
        await loadInitialPage()
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
        guard let navigation = navigation else {
            errorMessage = "未选择导航项"
            return
        }
        
        do {
            let newItems: [Topic]
            switch navigation.type {
            case "top":
                newItems = try await repository.fetchTopTopics()
            case "global":
                // 热帖：使用全局热帖接口
                newItems = try await repository.fetchHotTopics(page: nextPage, pageSize: pageSize)
            case "channel":
                // 频道：使用频道接口，使用 navigation.value 作为 channelID
                newItems = try await repository.fetchChannelTopics(channelID: navigation.value, page: nextPage, pageSize: pageSize)
            case "album":
                // 图览：使用图览接口
                newItems = try await repository.fetchAlbumTopics(page: nextPage, pageSize: pageSize)
            default:
                newItems = []
                errorMessage = "不支持的导航类型：\(navigation.type)"
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

