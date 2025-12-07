//
//  DraftViewModel.swift
//  Smth
//
//  Loads drafts for the current user.
//

import Foundation

@MainActor
final class DraftViewModel: ObservableObject {
    @Published private(set) var drafts: [Draft] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: DraftRepositoryProtocol

    init(repository: DraftRepositoryProtocol = DraftRepository()) {
        self.repository = repository
    }

    func loadDraftsIfNeeded() async {
        guard drafts.isEmpty else { return }
        await loadDrafts()
    }

    func loadDrafts(sort: String = "asc") async {
        isLoading = true
        errorMessage = nil
        do {
            drafts = try await repository.fetchDrafts(sort: sort)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func refresh() async {
        await loadDrafts()
    }
}

