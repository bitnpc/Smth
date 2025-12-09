//
//  AllSectionsViewModel.swift
//  Smth
//
//  所有版块视图模型，管理完整版块层级列表的加载
//  Created by tony
//

import Foundation

@MainActor
final class AllSectionsViewModel: ObservableObject {
    @Published private(set) var sections: [SMSection] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: SectionRepositoryProtocol

    init(repository: SectionRepositoryProtocol = AppContainer.shared.resolve(SectionRepositoryProtocol.self)) {
        self.repository = repository
    }

    func loadSectionsIfNeeded() async {
        guard sections.isEmpty else { return }
        await loadSections()
    }

    func loadSections() async {
        isLoading = true
        errorMessage = nil
        do {
            sections = try await repository.fetchAllSections()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}


