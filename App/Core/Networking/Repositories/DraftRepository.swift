//
//  DraftRepository.swift
//  Smth
//
//  Handles draft related network requests.
//

import Foundation
import Alamofire

protocol DraftRepositoryProtocol {
    func fetchDrafts(sort: String) async throws -> [Draft]
}

struct DraftRepository: DraftRepositoryProtocol {
    func fetchDrafts(sort: String = "asc") async throws -> [Draft] {
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let parameters = [
            "t": timestamp,
            "sort": sort
        ]
        do {
            let response = try await AF.request(APIRouter.drafts(parameters: parameters))
                .serializingDecodable(DraftResponse.self)
                .value
            
            guard response.code == 1 else {
                throw AppError.businessError(response.message)
            }
            
            return response.data
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }
}

struct StubDraftRepository: DraftRepositoryProtocol {
    var fetchDrafts: (_ sort: String) async throws -> [Draft]
    
    init(
        fetchDrafts: @escaping (_ sort: String) async throws -> [Draft] = { _ in [] }
    ) {
        self.fetchDrafts = fetchDrafts
    }
    
    func fetchDrafts(sort: String) async throws -> [Draft] {
        try await fetchDrafts(sort)
    }
}

