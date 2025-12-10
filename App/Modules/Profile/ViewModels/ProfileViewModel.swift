//
//  ProfileViewModel.swift
//  Smth
//
//  个人资料视图模型，管理用户个人资料的加载和显示
//  Created by tony
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: Profile = .defaultProfile
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: UserRepositoryProtocol
    private var hasLoaded = false

    init(repository: UserRepositoryProtocol = AppContainer.shared.resolve(UserRepositoryProtocol.self)) {
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
