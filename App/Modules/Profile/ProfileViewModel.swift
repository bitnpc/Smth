//
//  ProfileViewModel.swift
//  Smth
//
//  Loads user profile data for Mine tab.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: Profile = .defaultProfile
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: UserRepositoryProtocol
    private var hasLoaded = false

    init(repository: UserRepositoryProtocol = UserRepository()) {
        self.repository = repository
    }

    func loadProfileIfNeeded() async {
        guard hasLoaded == false else { return }
        await loadProfile()
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        do {
            profile = try await repository.fetchProfile()
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func reset() {
        profile = .defaultProfile
        isLoading = false
        errorMessage = nil
        hasLoaded = false
    }
}


