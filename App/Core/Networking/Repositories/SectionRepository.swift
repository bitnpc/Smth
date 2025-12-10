//
//  SectionRepository.swift
//  Smth
//
//  版块相关的数据仓库，负责获取版块列表、收藏版块、收藏话题等
//  Created by tony
//

import Foundation

protocol SectionRepositoryProtocol {
    func fetchFavoriteBoards() async throws -> [FavBoard]
    func fetchFavoriteTopics(sort: String, page: Int, pageSize: Int) async throws -> [Topic]
    func fetchFavoriteTopicsWithInfo(sort: String, page: Int, pageSize: Int) async throws -> [FavTopic]
    func fetchAllSections() async throws -> [SMSection]
    func fetchBoards(in sectionID: String) async throws -> [Board]
}

struct SectionRepository: SectionRepositoryProtocol {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchFavoriteBoards() async throws -> [FavBoard] {
        let endpoint = APIEndpoint.favoriteBoards.toEndpoint()
        let response: FavBoardResponse = try await apiService.request(endpoint)
        return response.data.favBoards
    }
    
    func fetchFavoriteTopics(sort: String, page: Int, pageSize: Int) async throws -> [Topic] {
        let favTopics = try await fetchFavoriteTopicsWithInfo(sort: sort, page: page, pageSize: pageSize)
        return favTopics.map { $0.topic }
    }
    
    func fetchFavoriteTopicsWithInfo(sort: String, page: Int, pageSize: Int) async throws -> [FavTopic] {
        let endpoint = APIEndpoint.favoriteTopics(sort: sort, page: page, pageSize: pageSize).toEndpoint()
        let response: FavTopicResponse = try await apiService.request(endpoint)
        return response.data.favTopic
    }

    func fetchAllSections() async throws -> [SMSection] {
        let endpoint = APIEndpoint.allSections.toEndpoint()
        let response: SectionResponse = try await apiService.request(endpoint)
        return response.data.sections
    }

    func fetchBoards(in sectionID: String) async throws -> [Board] {
        let endpoint = APIEndpoint.boards(sectionID: sectionID).toEndpoint()
        let response: BoardResponse = try await apiService.request(endpoint)
        return response.data.boards
    }
}

struct StubSectionRepository: SectionRepositoryProtocol {
    var favBoards: () async throws -> [FavBoard]
    var favTopics: (_ sort: String, _ page: Int, _ pageSize: Int) async throws -> [Topic]
    var favTopicsWithInfo: (_ sort: String, _ page: Int, _ pageSize: Int) async throws -> [FavTopic]
    var sections: () async throws -> [SMSection]
    var boards: (_ sectionID: String) async throws -> [Board]

    init(
        favBoards: @escaping () async throws -> [FavBoard] = { [] },
        favTopics: @escaping (_ sort: String, _ page: Int, _ pageSize: Int) async throws -> [Topic] = { _, _, _ in [] },
        favTopicsWithInfo: @escaping (_ sort: String, _ page: Int, _ pageSize: Int) async throws -> [FavTopic] = { _, _, _ in [] },
        sections: @escaping () async throws -> [SMSection] = { [] },
        boards: @escaping (_ sectionID: String) async throws -> [Board] = { _ in [] }
    ) {
        self.favBoards = favBoards
        self.favTopics = favTopics
        self.favTopicsWithInfo = favTopicsWithInfo
        self.sections = sections
        self.boards = boards
    }

    func fetchFavoriteBoards() async throws -> [FavBoard] {
        try await favBoards()
    }
    
    func fetchFavoriteTopics(sort: String, page: Int, pageSize: Int) async throws -> [Topic] {
        try await favTopics(sort, page, pageSize)
    }
    
    func fetchFavoriteTopicsWithInfo(sort: String, page: Int, pageSize: Int) async throws -> [FavTopic] {
        try await favTopicsWithInfo(sort, page, pageSize)
    }

    func fetchAllSections() async throws -> [SMSection] {
        try await sections()
    }

    func fetchBoards(in sectionID: String) async throws -> [Board] {
        try await boards(sectionID)
    }
}
