//
//  FansViewModel.swift
//  Smth
//
//  Loads fans list for the current user.
//

import Foundation

@MainActor
final class FansViewModel: ObservableObject {
    @Published private(set) var fans: [Friend] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: UserRepositoryProtocol
    private let userName: String

    init(userName: String, repository: UserRepositoryProtocol = UserRepository()) {
        self.userName = userName
        self.repository = repository
    }

    func loadFansIfNeeded() async {
        guard fans.isEmpty else { return }
        await loadFans()
    }

    func loadFans() async {
        isLoading = true
        errorMessage = nil
        do {
            let data = try await repository.fetchFans(name: userName)
            fans = data.fans
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func refresh() async {
        await loadFans()
    }
}

