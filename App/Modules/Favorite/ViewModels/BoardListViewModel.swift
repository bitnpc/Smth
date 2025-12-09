//
//  BoardListViewModel.swift
//  Smth
//
//  版块列表视图模型，管理版块列表的加载和分组显示
//  Created by tony
//

import Foundation

@MainActor
final class BoardListViewModel: ObservableObject {
    @Published private(set) var boards: [Board] = []
    @Published private(set) var filteredBoards: [Board] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let sectionID: String
    private let repository: SectionRepositoryProtocol

    init(sectionID: String, repository: SectionRepositoryProtocol = AppContainer.shared.resolve(SectionRepositoryProtocol.self)) {
        self.sectionID = sectionID
        self.repository = repository
    }

    func loadBoardsIfNeeded() async {
        guard boards.isEmpty else { return }
        await loadBoards()
    }

    func loadBoards() async {
        isLoading = true
        errorMessage = nil
        do {
            boards = try await repository.fetchBoards(in: sectionID)
            filteredBoards = BoardListViewModel.primaryBoards(from: boards)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func subBoards(for board: Board) -> [Board] {
        boards.filter { $0.groupId == board.id }
    }

    private static func primaryBoards(from boards: [Board]) -> [Board] {
        let groupIDs = Set(boards.map { $0.id })
        return boards.filter { board in
            (board.type == 0 && !groupIDs.contains(board.groupId)) || (board.type == 1 && board.groupId.isEmpty)
        }
    }
}


