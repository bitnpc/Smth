//
//  APIError.swift
//  Smth
//
//  应用程序错误类型定义，统一管理网络、解码、业务等错误
//  Created by tony
//

import Foundation

enum AppError: Error, LocalizedError, Equatable {
    case invalidResponse
    case network(message: String)
    case decoding(message: String)
    case businessError(String)
    case unknown(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "服务器返回了无效的数据。"
        case let .network(message):
            return message
        case let .decoding(message):
            return message
        case let .businessError(message):
            return message
        case let .unknown(message):
            return message
        }
    }

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}

extension AppError {
    static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        if let decodingError = error as? DecodingError {
            return .decoding(message: decodingError.localizedDescription)
        }
        if let urlError = error as? URLError {
            return .network(message: urlError.localizedDescription)
        }
        return .unknown(message: error.localizedDescription)
    }

    static func network(_ error: Error) -> AppError {
        if let urlError = error as? URLError {
            return .network(message: urlError.localizedDescription)
        }
        return .network(message: error.localizedDescription)
    }
}

@available(*, deprecated, message: "请使用 AppError 替代 APIError")
typealias APIError = AppError
