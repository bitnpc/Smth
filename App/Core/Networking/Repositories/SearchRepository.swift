//
//  SearchRepository.swift
//  Smth
//
//  Handles search related network requests.
//

import Foundation
import Alamofire

protocol SearchRepositoryProtocol {
    func searchArticles(keyword: String, start: Int, count: Int, original: Bool, earliest: String?, boards: String?, status: Int) async throws -> SearchData
}

struct SearchRepository: SearchRepositoryProtocol {
    func searchArticles(keyword: String, start: Int, count: Int, original: Bool, earliest: String?, boards: String?, status: Int) async throws -> SearchData {
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        var parameters: [String: String] = [
            "t": timestamp,
            "keyword": keyword,
            "count": String(count),
            "start": String(start),
            "original": original ? "true" : "false",
            "status": String(status)
        ]
        
        if let earliest = earliest {
            parameters["earliest"] = earliest
        }
        
        if let boards = boards {
            parameters["boards"] = boards
        }
        
        do {
            let response = try await AF.request(APIRouter.searchArticle(parameters: parameters))
                .serializingDecodable(SearchResponse.self)
                .value
            
            return response.data
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }
}

