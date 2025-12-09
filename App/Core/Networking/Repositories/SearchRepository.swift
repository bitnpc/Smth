//
//  SearchRepository.swift
//  Smth
//
//  搜索相关的数据仓库，负责文章搜索功能
//  Created by tony
//

import Foundation

protocol SearchRepositoryProtocol {
    func searchArticles(keyword: String, start: Int, count: Int, original: Bool, earliest: String?, boards: String?, status: Int) async throws -> SearchData
}

struct SearchRepository: SearchRepositoryProtocol {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func searchArticles(keyword: String, start: Int, count: Int, original: Bool, earliest: String?, boards: String?, status: Int) async throws -> SearchData {
        let endpoint = APIEndpoint.searchArticle(
            keyword: keyword,
            start: start,
            count: count,
            original: original,
            earliest: earliest,
            boards: boards,
            status: status
        ).toEndpoint()
        
        let response: SearchResponse = try await apiService.request(endpoint)
        return response.data
    }
}

