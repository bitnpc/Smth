//
//  DraftRepository.swift
//  Smth
//
//  草稿相关的数据仓库，负责获取用户草稿列表
//  Created by tony
//

import Foundation

protocol DraftRepositoryProtocol {
    func fetchDrafts(sort: String) async throws -> [Draft]
}

struct DraftRepository: DraftRepositoryProtocol {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchDrafts(sort: String = "asc") async throws -> [Draft] {
        let endpoint = APIEndpoint.drafts(sort: sort).toEndpoint()
        let response: DraftResponse = try await apiService.request(endpoint)
        
        guard response.code == 1 else {
            throw AppError.businessError(response.message)
        }
        
        return response.data
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

