//
//  HomeNavigationViewModel.swift
//  Smth
//
//  首页视图模型，管理导航数据的加载和状态
//  Created by tony
//

import Foundation

@MainActor
final class HomeNavigationViewModel: ObservableObject {
    @Published private(set) var navigations: [Navigation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let repository: UserRepositoryProtocol
    private var hasLoaded = false
    
    init(repository: UserRepositoryProtocol = AppContainer.shared.resolve(UserRepositoryProtocol.self)) {
        self.repository = repository
    }
    
    func loadNavigationsIfNeeded() async {
        guard !hasLoaded else { return }
        await loadNavigations()
    }
    
    func loadNavigations() async {
        isLoading = true
        errorMessage = nil
        do {
            var items = try await repository.fetchNavigation()
            items.insert(Navigation.topNavigation(), at: 0)
            navigations = items
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func reset() {
        navigations = []
        isLoading = false
        errorMessage = nil
        hasLoaded = false
    }
}

