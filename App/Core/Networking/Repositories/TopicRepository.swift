//
//  TopicRepository.swift
//  Smth
//
//  Created as part of the 2025 refactor.
//

import Foundation
import Alamofire

protocol TopicRepositoryProtocol {
    func fetchHotTopics(page: Int, pageSize: Int) async throws -> [Topic]
    func fetchTopics(in boardID: String, page: Int, pageSize: Int) async throws -> [Topic]
    func fetchMyTopics(page: Int) async throws -> [Article]
    func fetchTopicDetail(topicID: String, page: Int, sortType: SortType) async throws -> TopicDetail
}

struct TopicRepository: TopicRepositoryProtocol {
    private let api: ForumAPI

    init(api: ForumAPI = .live) {
        self.api = api
    }

    func fetchHotTopics(page: Int, pageSize: Int) async throws -> [Topic] {
        do {
            return try await api.hotTopics(page, pageSize)
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }

    func fetchTopics(in boardID: String, page: Int, pageSize: Int) async throws -> [Topic] {
        do {
            return try await api.boardTopics(boardID, page, pageSize)
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }

    func fetchMyTopics(page: Int) async throws -> [Article] {
        let ts = String(Int(Date().timeIntervalSince1970 * 1000))
        let parameters = [
            "t": ts,
            "type": "0",
            "page": String(page),
            "sort": "DESC"
        ]
        do {
            let response = try await AF.request(APIRouter.myTopic(parameters))
                .serializingDecodable(ArticleResponse.self)
                .value
            return response.data.articles
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }

    func fetchTopicDetail(topicID: String, page: Int, sortType: SortType) async throws -> TopicDetail {
        let ts = String(Int(Date().timeIntervalSince1970 * 1000))
        let parameters = ["t": ts]
        let request = APIRouter.article(topicID: topicID, page: page, sortType: sortType, parameters: parameters)
        do {
            let responseString = try await AF.request(request).serializingString().value
            guard let data = responseString.data(using: .utf8) else {
                throw AppError.invalidResponse
            }
            let detail = try TopicRepository.decodeTopicDetail(from: data)
            return detail
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }

    private static func decodeTopicDetail(from data: Data) throws -> TopicDetail {
        do {
            if var jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               var dataDict = jsonObject["data"] as? [String: Any],
               var articles = dataDict["articles"] as? [Any],
               var firstArticle = articles.first as? [String: Any] {
                if let attachments = firstArticle["attachments"] as? [Any] {
                    firstArticle["attachments"] = attachments.compactMap { $0 as? [String: Any] }
                    articles[0] = firstArticle
                    dataDict["articles"] = articles
                    jsonObject["data"] = dataDict
                    let normalizedData = try JSONSerialization.data(withJSONObject: jsonObject)
                    let response = try JSONDecoder().decode(TopicDetailResponse.self, from: normalizedData)
                    return response.data
                }
            }
            let response = try JSONDecoder().decode(TopicDetailResponse.self, from: data)
            return response.data
        } catch {
            throw AppError.decoding(message: "帖子详情解析失败。")
        }
    }
}

struct StubTopicRepository: TopicRepositoryProtocol {
    var hotTopics: (_ page: Int, _ size: Int) async throws -> [Topic]
    var boardTopics: (_ boardID: String, _ page: Int, _ size: Int) async throws -> [Topic]
    var myTopics: (_ page: Int) async throws -> [Article]
    var topicDetail: (_ topicID: String, _ page: Int, _ sortType: SortType) async throws -> TopicDetail

    init(
        hotTopics: @escaping (_ page: Int, _ size: Int) async throws -> [Topic] = { _, _ in [] },
        boardTopics: @escaping (_ boardID: String, _ page: Int, _ size: Int) async throws -> [Topic] = { _, _, _ in [] },
        myTopics: @escaping (_ page: Int) async throws -> [Article] = { _ in [] },
        topicDetail: @escaping (_ topicID: String, _ page: Int, _ sortType: SortType) async throws -> TopicDetail = { _, _, _ in
            TopicDetail(
                topic: Topic(
                    id: UUID().uuidString,
                    subject: "Stub Topic",
                    availables: 0,
                    likeAvailables: 0,
                    flushTime: Date().timeIntervalSince1970,
                    board: nil,
                    article: nil
                ),
                articles: [],
                board: Board(id: UUID().uuidString, title: "Stub Board", isFavorite: 0, groupId: "", type: 0, name: "")
            )
        }
    ) {
        self.hotTopics = hotTopics
        self.boardTopics = boardTopics
        self.myTopics = myTopics
        self.topicDetail = topicDetail
    }

    func fetchHotTopics(page: Int, pageSize: Int) async throws -> [Topic] {
        try await hotTopics(page, pageSize)
    }

    func fetchTopics(in boardID: String, page: Int, pageSize: Int) async throws -> [Topic] {
        try await boardTopics(boardID, page, pageSize)
    }

    func fetchMyTopics(page: Int) async throws -> [Article] {
        try await myTopics(page)
    }

    func fetchTopicDetail(topicID: String, page: Int, sortType: SortType) async throws -> TopicDetail {
        try await topicDetail(topicID, page, sortType)
    }
}


