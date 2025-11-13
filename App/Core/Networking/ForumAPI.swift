//
//  ForumAPI.swift
//  Smth
//
//  Created as part of the 2025 refactor.
//

import Foundation
import Alamofire

struct ForumAPI {
    var hotTopics: @Sendable (_ page: Int, _ pageSize: Int) async throws -> [Topic]
    var topTopics: @Sendable () async throws -> [Topic]
    var boardTopics: @Sendable (_ boardID: String, _ page: Int, _ pageSize: Int) async throws -> [Topic]
}

extension ForumAPI {
    static let live = ForumAPI(
        hotTopics: { page, size in
            let ts = String(Int(Date().timeIntervalSince1970 * 1000))
            let parameters = [
                "t": ts,
                "page": String(page),
                "size": String(size)
            ]
            let response = try await AF.request(APIRouter.hot(parameters))
                .serializingDecodable(TopicResponse.self)
                .value
            return response.data.topics
        },
        topTopics: {
            let ts = String(Int(Date().timeIntervalSince1970 * 1000))
            let parameters = [
                "t": ts,
                "page": "1",
                "size": "20"
            ]
            let response = try await AF.request(APIRouter.top(parameters))
                .serializingDecodable(TopicResponse.self)
                .value
            return response.data.topics
        },
        boardTopics: { boardID, page, size in
            let ts = String(Int(Date().timeIntervalSince1970 * 1000))
            let parameters = [
                "t": ts,
                "id": boardID,
                "isOrderByFlushTime": "1",
                "page": String(page),
                "size": String(size)
            ]
            let response = try await AF.request(APIRouter.topicList(parameters))
                .serializingDecodable(TopicResponse.self)
                .value
            return response.data.topics
        }
    )
}

extension ForumAPI {
    static let preview = ForumAPI(
        hotTopics: { _, _ in Topic.previewSamples },
        topTopics: { Topic.previewSamples },
        boardTopics: { _, _, _ in Topic.previewSamples }
    )
}

private extension Topic {
    static let previewSamples: [Topic] = [
        .init(
            id: UUID().uuidString,
            subject: "欢迎来到新闻站",
            availables: 0,
            likeAvailables: 0,
            flushTime: Date().timeIntervalSince1970,
            board: nil,
            article: nil
        ),
        .init(
            id: UUID().uuidString,
            subject: "SwiftUI 最佳实践",
            availables: 0,
            likeAvailables: 0,
            flushTime: Date().addingTimeInterval(-3600).timeIntervalSince1970,
            board: nil,
            article: nil
        )
    ]
}


