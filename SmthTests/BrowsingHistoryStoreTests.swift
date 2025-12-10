import XCTest
@testable import Smth

final class BrowsingHistoryStoreTests: XCTestCase {
    private var tempURL: URL!

    override func setUp() {
        super.setUp()
        tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempURL)
        tempURL = nil
        super.tearDown()
    }

    func testRecordAddsNewEntry() {
        let store = BrowsingHistoryStore(storageURL: tempURL)
        let topic = makeTopic(id: "topic-1", subject: "测试主题")

        store.record(topic)

        XCTAssertEqual(store.entries.count, 1)
        XCTAssertTrue(store.visitedTopicIDs.contains(topic.id))
        XCTAssertEqual(store.entries.first?.subject, "测试主题")
    }

    func testRecordMovesExistingEntryToTop() {
        let store = BrowsingHistoryStore(storageURL: tempURL)
        let first = makeTopic(id: "first", subject: "第一条")
        let second = makeTopic(id: "second", subject: "第二条")

        store.record(first)
        store.record(second)

        XCTAssertEqual(store.entries.map(\.id), ["second", "first"])

        store.record(first)

        XCTAssertEqual(store.entries.map(\.id), ["first", "second"])
    }

    private func makeTopic(id: String, subject: String) -> Topic {
        Topic(
            id: id,
            subject: subject,
            availables: 0,
            likeAvailables: 0,
            flushTime: 0,
            board: Board(id: "board", title: "测试版面", isFavorite: 0, groupId: "", type: 0, name: ""),
            article: nil
        )
    }
}
