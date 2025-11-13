//
//  APIRouter.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    case hot([String: String])
    case topicList([String: String])
    case article(topicID: String, page: Int, sortType: SortType, parameters: [String: String])
    case section([String: String])
    case favBoard([String: String])
    case favTopic([String: String])
    case board([String: String])
    case profile([String: String])
    case myTopic([String: String])

    private var baseURL: URL {
        URL(string: "https://wap.newsmth.net")!
    }

    private var method: HTTPMethod {
        switch self {
        case .profile: return .post
        default: return .get
        }
    }

    private var path: String {
        switch self {
        case .hot: return "wap/api/hot/global"
        case .topicList: return "wap/api/board/topic/list"
        case let .article(topicID, page, sortType, _):
            return "wap/api/topic/loadArticlesByMode/\(topicID)/\(sortType.rawValue)/\(page)/20"
        case .section: return "wap/api/section/all"
        case .favBoard: return "wap/api/profile/fav/boards"
        case .favTopic: return "wap/api/profile/fav/topics"
        case .board: return "wap/api/section/subs"
        case .profile: return "wap/api/profile"
        case .myTopic: return "wap/api/profile/myarticle"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method

        switch self {
        case let .hot(parameters),
             let .topicList(parameters),
             let .article(_, _, _, parameters),
             let .section(parameters),
             let .favBoard(parameters),
            let .favTopic(parameters),
             let .board(parameters),
             let .profile(parameters),
             let .myTopic(parameters):
            request = try URLEncodedFormParameterEncoder().encode(parameters, into: request)
        }
        return request
    }
}


