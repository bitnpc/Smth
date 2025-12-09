//
//  APIService.swift
//  Smth
//
//  网络请求服务协议和实现，提供统一的网络请求接口
//  Created by tony
//

import Foundation

protocol APIService {
    /// 发送请求并解码为指定类型
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    
    /// 发送请求并返回原始字符串
    func requestString(_ endpoint: Endpoint) async throws -> String
    
    /// 发送请求并返回原始数据
    func requestData(_ endpoint: Endpoint) async throws -> Data
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
        let data = try await requestData(endpoint)
        do {
            return try configuration.decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw AppError.decoding(message: decodingError.localizedDescription)
        }
    }
    
    func requestString(_ endpoint: Endpoint) async throws -> String {
        let data = try await requestData(endpoint)
        guard let string = String(data: data, encoding: .utf8) else {
            throw AppError.decoding(message: "无法将响应数据转换为字符串")
        }
        return string
    }
    
    func requestData(_ endpoint: Endpoint) async throws -> Data {
        let request = try endpoint.makeRequest(baseURL: configuration.baseURL)
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.businessError("服务器没有返回正确响应。")
            }
            guard 200..<300 ~= httpResponse.statusCode else {
                throw AppError.businessError("服务器返回错误状态码：\(httpResponse.statusCode)")
            }
            return data
        } catch let urlError as URLError {
            throw AppError.network(message: urlError.localizedDescription)
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.unknown(message: error.localizedDescription)
        }
    }
}

