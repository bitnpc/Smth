//
//  SectionRepository.swift
//  Smth
//
//  Handles section and board related network requests.
//

import Foundation
import Alamofire

protocol SectionRepositoryProtocol {
    func fetchFavoriteBoards() async throws -> [FavBoard]
    func fetchFavoriteTopics() async throws -> [Topic]
    func fetchAllSections() async throws -> [SMSection]
    func fetchBoards(in sectionID: String) async throws -> [Board]
}

struct SectionRepository: SectionRepositoryProtocol {
    func fetchFavoriteBoards() async throws -> [FavBoard] {
        do {
            let response = try await AF.request(APIRouter.favBoard([:]))
                .serializingDecodable(FavBoardResponse.self)
                .value
            return response.data.favBoards
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }
    
    func fetchFavoriteTopics() async throws -> [Topic] {
        do {
            let response = try await AF.request(APIRouter.favTopic([:]))
                .serializingDecodable(TopicResponse.self)
                .value
            return response.data.topics
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }

    func fetchAllSections() async throws -> [SMSection] {
        do {
            let response = try await AF.request(APIRouter.section([:]))
                .serializingDecodable(SectionResponse.self)
                .value
            return response.data.sections
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }

    func fetchBoards(in sectionID: String) async throws -> [Board] {
        let ts = String(Int(Date().timeIntervalSince1970 * 1000))
        let parameters = [
            "t": ts,
            "id": sectionID
        ]
        do {
            let response = try await AF.request(APIRouter.board(parameters))
                .serializingDecodable(BoardResponse.self)
                .value
            return response.data.boards
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }
}

struct StubSectionRepository: SectionRepositoryProtocol {
    var favBoards: () async throws -> [FavBoard]
    var favTopics: () async throws -> [Topic]
    var sections: () async throws -> [SMSection]
    var boards: (_ sectionID: String) async throws -> [Board]

    init(
        favBoards: @escaping () async throws -> [FavBoard] = { [] },
        favTopics: @escaping () async throws -> [Topic] = { [] },
        sections: @escaping () async throws -> [SMSection] = { [] },
        boards: @escaping (_ sectionID: String) async throws -> [Board] = { _ in [] }
    ) {
        self.favBoards = favBoards
        self.favTopics = favTopics
        self.sections = sections
        self.boards = boards
    }

    func fetchFavoriteBoards() async throws -> [FavBoard] {
        try await favBoards()
    }
    
    func fetchFavoriteTopics() async throws -> [Topic] {
        try await favTopics()
    }

    func fetchAllSections() async throws -> [SMSection] {
        try await sections()
    }

    func fetchBoards(in sectionID: String) async throws -> [Board] {
        try await boards(sectionID)
    }
}


