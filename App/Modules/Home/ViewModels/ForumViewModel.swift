//
//  ForumViewModel.swift
//  Smth
//
//  Created as part of the 2025 refactor.
//

import Foundation
import Observation

@Observable
@MainActor
final class ForumViewModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(AppError)
    }

    private let repository: ForumRepository

    var topics: [Topic] = []
    var state: LoadState = .idle
    var lastResult: Result<[Topic], AppError>?

    init(repository: ForumRepository) {
        self.repository = repository
    }

    func load() async {
        guard state != .loading else { return }
        state = .loading
        do {
            let topics = try await repository.fetchHotTopics(page: 1, size: 20)
            lastResult = .success(topics)
            self.topics = topics
            state = .loaded
        } catch let error as AppError {
            lastResult = .failure(error)
            state = .failed(error)
        } catch {
            let appError = AppError.from(error)
            lastResult = .failure(appError)
            state = .failed(appError)
        }
    }
}

