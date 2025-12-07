//
//  APIRouter.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    case top([String: String])
    case hot([String: String])
    case topicList([String: String])
    case article(topicID: String, page: Int, sortType: SortType, parameters: [String: String])
    case section([String: String])
    case favBoard([String: String])
    case favTopic(sort: String, page: Int, pageSize: Int, parameters: [String: String])
    case board([String: String])
    case profile([String: String])
    case myTopic([String: String])
    case conversations(parameters: [String: String])
    case notify(type: Int, page: Int, parameters: [String: String])
    case conversationMessages(speakerId: String, page: Int, parameters: [String: String])
    case markConversationRead(speakerId: String, parameters: [String: String])

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
        case .top: return "wap/api/hot/ten"
        case .hot: return "wap/api/hot/global"
        case .topicList: return "wap/api/board/topic/list"
        case let .article(topicID, page, sortType, _):
            return "wap/api/topic/loadArticlesByMode/\(topicID)/\(sortType.rawValue)/\(page)/20"
        case .section: return "wap/api/section/all"
        case .favBoard: return "wap/api/profile/fav/boards"
        case let .favTopic(sort, page, pageSize, _):
            return "wap/api/profile/favTopic/\(sort)/\(page)/\(pageSize)"
        case .board: return "wap/api/section/subs"
        case .profile: return "wap/api/profile"
        case .myTopic: return "wap/api/profile/myarticle"
        case .conversations: return "wap/api/message/conversations"
        case let .notify(type, page, _): return "wap/api/notify/\(type)/\(page)"
        case let .conversationMessages(speakerId, page, _): return "wap/api/message/\(speakerId)/messages/\(page)"
        case .markConversationRead: return "wap/api/message/read"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method

        switch self {
        case let .hot(parameters),
            let .top(parameters),
             let .topicList(parameters),
             let .article(_, _, _, parameters),
             let .section(parameters),
             let .favBoard(parameters),
            let .favTopic(_, _, _, parameters),
             let .board(parameters),
             let .profile(parameters),
             let .myTopic(parameters),
             let .conversations(parameters),
             let .notify(_, _, parameters),
             let .conversationMessages(_, _, parameters),
             let .markConversationRead(_, parameters):
            request = try URLEncodedFormParameterEncoder().encode(parameters, into: request)
        }
        return request
    }
}


