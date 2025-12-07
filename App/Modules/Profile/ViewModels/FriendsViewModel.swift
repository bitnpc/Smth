//
//  FriendsViewModel.swift
//  Smth
//
//  Loads friends list for the current user.
//

import Foundation

@MainActor
final class FriendsViewModel: ObservableObject {
    @Published private(set) var friends: [Friend] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: UserRepositoryProtocol
    private let userName: String

    init(userName: String, repository: UserRepositoryProtocol = UserRepository()) {
        self.userName = userName
        self.repository = repository
    }

    func loadFriendsIfNeeded() async {
        guard friends.isEmpty else { return }
        await loadFriends()
    }

    func loadFriends() async {
        isLoading = true
        errorMessage = nil
        do {
            let data = try await repository.fetchFriends(name: userName)
            friends = data.friends
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func refresh() async {
        await loadFriends()
    }
}

