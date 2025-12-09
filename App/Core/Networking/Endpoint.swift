//
//  Endpoint.swift
//  Smth
//
//  网络请求端点结构定义，封装请求路径、方法、参数等信息
//  Created by tony
//

import Foundation

struct Endpoint {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    var path: String
    var method: Method = .get
    var queryItems: [URLQueryItem] = []
    var headers: [String: String] = [:]
    var body: Data?

    func makeRequest(baseURL: URL) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw AppError.businessError("无法构建 URL：\(path)")
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw AppError.businessError("URLComponents 无法生成有效 URL。")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = body
        return request
    }
}


