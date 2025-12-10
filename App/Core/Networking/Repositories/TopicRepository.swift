//
//  TopicRepository.swift
//  Smth
//
//  话题相关的数据仓库，负责获取热门话题、版块话题、话题详情等
//  Created by tony
//

import Foundation

protocol TopicRepositoryProtocol {
    func fetchHotTopics(page: Int, pageSize: Int) async throws -> [Topic]
    func fetchTopTopics() async throws -> [Topic]
    func fetchTopics(in boardID: String, page: Int, pageSize: Int) async throws -> [Topic]
    func fetchMyTopics(page: Int) async throws -> [Article]
    func fetchTopicDetail(topicID: String, page: Int, sortType: SortType) async throws -> TopicDetail
}

struct TopicRepository: TopicRepositoryProtocol {
    private let apiService: APIService

    init(apiService: APIService) {
        self.apiService = apiService
    }

    func fetchHotTopics(page: Int, pageSize: Int) async throws -> [Topic] {
        let endpoint = APIEndpoint.hotTopics(page: page, pageSize: pageSize).toEndpoint()
        let response: TopicResponse = try await apiService.request(endpoint)
        return response.data.topics
    }
    
    func fetchTopTopics() async throws -> [Topic] {
        let endpoint = APIEndpoint.topTopics.toEndpoint()
        let response: TopicResponse = try await apiService.request(endpoint)
        return response.data.topics
    }

    func fetchTopics(in boardID: String, page: Int, pageSize: Int) async throws -> [Topic] {
        let endpoint = APIEndpoint.topicList(boardID: boardID, page: page, pageSize: pageSize).toEndpoint()
        let response: TopicResponse = try await apiService.request(endpoint)
        return response.data.topics
    }

    func fetchMyTopics(page: Int) async throws -> [Article] {
        let endpoint = APIEndpoint.myTopics(page: page).toEndpoint()
        let response: ArticleResponse = try await apiService.request(endpoint)
        return response.data.articles
    }

    func fetchTopicDetail(topicID: String, page: Int, sortType: SortType) async throws -> TopicDetail {
        let endpoint = APIEndpoint.topicDetail(topicID: topicID, page: page, sortType: sortType).toEndpoint()
        let responseString = try await apiService.requestString(endpoint)
        guard let data = responseString.data(using: .utf8) else {
            throw AppError.invalidResponse
        }
        return try TopicRepository.decodeTopicDetail(from: data)
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
    var topTopics: () async throws -> [Topic]
    var boardTopics: (_ boardID: String, _ page: Int, _ size: Int) async throws -> [Topic]
    var myTopics: (_ page: Int) async throws -> [Article]
    var topicDetail: (_ topicID: String, _ page: Int, _ sortType: SortType) async throws -> TopicDetail

    init(
        hotTopics: @escaping (_ page: Int, _ size: Int) async throws -> [Topic] = { _, _ in [] },
        topTopics: @escaping () async throws -> [Topic] = { [] },
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
        self.topTopics = topTopics
        self.boardTopics = boardTopics
        self.myTopics = myTopics
        self.topicDetail = topicDetail
    }

    func fetchHotTopics(page: Int, pageSize: Int) async throws -> [Topic] {
        try await hotTopics(page, pageSize)
    }
    
    func fetchTopTopics() async throws -> [Topic] {
        try await topTopics()
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
