import XCTest
@testable import Smth

final class TopicListViewModelTests: XCTestCase {
    func testInitialLoadFetchesTopics() async throws {
        let repository = StubTopicRepository(
            hotTopics: { page, size in
                Self.mockTopics(page: page, pageSize: size)
            },
            boardTopics: { _, _, _ in [] }
        )
        let viewModel = TopicListViewModel(repository: repository)

        await viewModel.loadInitialIfNeeded()

        XCTAssertEqual(viewModel.topics.count, 20)
        XCTAssertFalse(viewModel.isLoadingPage)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testPaginationAppendsTopics() async throws {
        let repository = StubTopicRepository(
            hotTopics: { page, size in
                Self.mockTopics(page: page, pageSize: size)
            },
            boardTopics: { _, _, _ in [] }
        )
        let viewModel = TopicListViewModel(repository: repository, pageSize: 5)

        await viewModel.loadInitialIfNeeded()
        XCTAssertEqual(viewModel.topics.count, 5)

        viewModel.loadNextPageIfNeeded(currentItem: viewModel.topics.last)
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(viewModel.topics.count, 10)
    }

    private static func mockTopics(page: Int, pageSize: Int) -> [Topic] {
        let board = Board(
            id: "board-\(page)",
            title: "测试版面",
            isFavorite: 0,
            groupId: "group",
            type: 0,
            name: "test"
        )
        return (0..<pageSize).map { index in
            Topic(
                id: "topic-\(page)-\(index)",
                subject: "话题 \(page)-\(index)",
                availables: (page - 1) * pageSize + index,
                likeAvailables: index,
                flushTime: Date().timeIntervalSince1970,
                board: board,
                article: nil
            )
        }
    }
}
