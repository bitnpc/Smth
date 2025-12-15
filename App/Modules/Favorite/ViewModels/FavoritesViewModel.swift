//
//  FavoritesViewModel.swift
//  Smth
//
//  收藏视图模型，管理收藏版块和收藏话题的加载和显示
//  Created by tony
//

import Foundation

enum FavoriteRoute: Hashable {
    case favBoardItem(FavBoardItem)
    case favTopic(Topic)
    case allSection
}

@MainActor
final class FavoritesViewModel: ObservableObject {

    @Published private(set) var favBoards: [FavBoard] = []
    @Published private(set) var favTopics: [Topic] = []
    @Published private(set) var favTopicsWithInfo: [FavTopic] = [] // 保存完整信息以便访问 hasNewReply
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingPage = false
    @Published private(set) var errorMessage: String?

    private let repository: SectionRepositoryProtocol
    private var paginationState = PaginationState<Topic>()
    private let pageSize = 20
    private let defaultSort = "desc" // 默认按回帖时间倒序

    init(repository: SectionRepositoryProtocol = AppContainer.shared.resolve(SectionRepositoryProtocol.self)) {
        self.repository = repository
    }

    func hasNewReply(for topicId: String) -> Bool {
        favTopicsWithInfo.first { $0.topic.id == topicId }?.hasNewReply ?? false
    }

    func loadFavoritesIfNeeded() async {
        guard favBoards.isEmpty, favTopics.isEmpty else { return }
        await loadFavoriteBoards()
        await loadInitialFavoriteTopics()
    }

    func loadFavoriteBoards() async {
        isLoading = true
        errorMessage = nil
        do {
            favBoards = try await repository.fetchFavoriteBoards()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadInitialFavoriteTopics() async {
        isLoading = true
        errorMessage = nil
        paginationState.reset()
        favTopics = []
        favTopicsWithInfo = []
        defer {
            isLoading = false
        }
        await loadFavoriteTopicsPage()
    }

    func loadNextFavoriteTopicsPage() async {
        guard !isLoadingPage else { return }
        await loadFavoriteTopicsPage()
    }

    private func loadFavoriteTopicsPage() async {
        let originalState = paginationState
        guard let nextPage = paginationState.startLoadingNextPage() else { return }
        isLoadingPage = true
        defer { isLoadingPage = false }

        do {
            let newFavTopics = try await repository.fetchFavoriteTopicsWithInfo(
                sort: defaultSort,
                page: nextPage - 1, // API 使用从 0 开始的页码，而 PaginationState 从 1 开始
                pageSize: pageSize
            )
            let newItems = newFavTopics.map { $0.topic }
            paginationState.completeLoading(with: newItems, pageSize: pageSize)
            favTopics = paginationState.items
            favTopicsWithInfo.append(contentsOf: newFavTopics)
        } catch {
            errorMessage = error.localizedDescription
            paginationState = originalState
            favTopics = originalState.items
        }
    }

    func reset() {
        favBoards = []
        favTopics = []
        favTopicsWithInfo = []
        paginationState.reset()
        isLoading = false
        isLoadingPage = false
        errorMessage = nil
    }
}
