//
//  APIService.swift
//  Smth
//
//  Created as part of the 2025 refactor.
//

import Foundation

protocol APIService {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

struct APIConfiguration {
    let baseURL: URL
    let decoder: JSONDecoder

    static let `default` = APIConfiguration(
        baseURL: URL(string: "https://wap.newsmth.net")!,
        decoder: {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return decoder
        }()
    )
}

final class DefaultAPIService: APIService {
    private let session: URLSession
    private let configuration: APIConfiguration

    init(session: URLSession = .shared, configuration: APIConfiguration = .default) {
        self.session = session
        self.configuration = configuration
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.makeRequest(baseURL: configuration.baseURL)
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.businessError("服务器没有返回正确响应。")
            }
            guard 200..<300 ~= httpResponse.statusCode else {
                throw AppError.businessError("服务器返回错误状态码：\(httpResponse.statusCode)")
            }
            do {
                return try configuration.decoder.decode(T.self, from: data)
            } catch let decodingError as DecodingError {
                throw AppError.decoding(message: decodingError.localizedDescription)
            }
        } catch let urlError as URLError {
            throw AppError.network(message: urlError.localizedDescription)
        } catch {
            throw AppError.unknown(message: error.localizedDescription)
        }
    }
}

