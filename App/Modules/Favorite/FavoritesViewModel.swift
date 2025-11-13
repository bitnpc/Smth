//
//  FavoritesViewModel.swift
//  Smth
//
//  Created by 仝超 on 2025/11/13.
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
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: SectionRepositoryProtocol

    init(repository: SectionRepositoryProtocol = SectionRepository()) {
        self.repository = repository
    }

    func loadFavoritesIfNeeded() async {
        guard favBoards.isEmpty, favTopics.isEmpty else { return }
        await loadFavoriteBoards()
        await loadFavoriteTopics()
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
    
    func loadFavoriteTopics() async {
        isLoading = true
        errorMessage = nil
        do {
            favTopics = try await repository.fetchFavoriteTopics()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func reset() {
        favBoards = []
        favTopics = []
        isLoading = false
        errorMessage = nil
    }
}
