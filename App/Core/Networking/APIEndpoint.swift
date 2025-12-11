//
//  APIEndpoint.swift
//  Smth
//
//  统一的 API 端点定义，将所有网络请求端点集中管理
//  Created by tony
//

import Foundation

/// API 端点构建器
enum APIEndpoint {
    // MARK: - 话题相关
    case hotTopics(page: Int, pageSize: Int)
    case topTopics
    case channelTopic(channelID: String, page: Int, pageSize: Int)
    case topicList(boardID: String, page: Int, pageSize: Int)
    case topicDetail(topicID: String, page: Int, sortType: SortType)
    case myTopics(page: Int)
    case albumTopics(page: Int, pageSize: Int)
    
    // MARK: - 版块相关
    case allSections
    case boards(sectionID: String)
    case favoriteBoards
    case favoriteTopics(sort: String, page: Int, pageSize: Int)
    
    // MARK: - 用户相关
    case profile
    case friends(name: String)
    case fans(name: String)
    case navigation
    
    // MARK: - 消息相关
    case conversations(page: Int)
    case notify(type: Int, page: Int)
    case conversationMessages(speakerId: String, page: Int)
    case markConversationRead(speakerId: String)
    
    // MARK: - 搜索相关
    case searchArticle(keyword: String, start: Int, count: Int, original: Bool, earliest: String?, boards: String?, status: Int)
    
    // MARK: - 草稿相关
    case drafts(sort: String)
    
    /// 转换为 Endpoint 结构
    func toEndpoint() -> Endpoint {
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        
        switch self {
        // MARK: - 话题相关
        case let .hotTopics(page, pageSize):
            return Endpoint(
                path: "wap/api/hot/global",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp),
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "size", value: String(pageSize))
                ]
            )
            
        case .topTopics:
            return Endpoint(
                path: "wap/api/hot/ten",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp),
                    URLQueryItem(name: "page", value: "1"),
                    URLQueryItem(name: "size", value: "20")
                ]
            )
            
        case let .channelTopic(boardID, page, pageSize):
            return Endpoint(
                path: "wap/api/channel/loadTopics",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp),
                    URLQueryItem(name: "channel", value: boardID),
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "size", value: String(pageSize))
                ]
            )
            
        case let .topicList(boardID, page, pageSize):
            return Endpoint(
                path: "wap/api/board/topic/list",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp),
                    URLQueryItem(name: "id", value: boardID),
                    URLQueryItem(name: "isOrderByFlushTime", value: "1"),
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "size", value: String(pageSize))
                ]
            )
            
        case let .topicDetail(topicID, page, sortType):
            return Endpoint(
                path: "wap/api/topic/loadArticlesByMode/\(topicID)/\(sortType.rawValue)/\(page)/20",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp)
                ]
            )
            
        case let .myTopics(page):
            return Endpoint(
                path: "wap/api/profile/myarticle",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp),
                    URLQueryItem(name: "type", value: "0"),
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "sort", value: "DESC")
                ]
            )
            
        case let .albumTopics(page, pageSize):
            return Endpoint(
                path: "wap/api/album/load/global",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp),
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "size", value: String(pageSize))
                ]
            )
            
        // MARK: - 版块相关
        case .allSections:
            return Endpoint(
                path: "wap/api/section/all",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp)
                ]
            )
            
        case let .boards(sectionID):
            return Endpoint(
                path: "wap/api/section/subs",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp),
                    URLQueryItem(name: "id", value: sectionID)
                ]
            )
            
        case .favoriteBoards:
            return Endpoint(
                path: "wap/api/profile/fav/boards",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp)
                ]
            )
            
        case let .favoriteTopics(sort, page, pageSize):
            return Endpoint(
                path: "wap/api/profile/favTopic/\(sort)/\(page)/\(pageSize)",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp)
                ]
            )
            
        // MARK: - 用户相关
        case .profile:
            return Endpoint(
                path: "wap/api/profile",
                method: .post,
                queryItems: []
            )
            
        case let .friends(name):
            return Endpoint(
                path: "wap/api/account/friends/\(name)",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp)
                ]
            )
            
        case let .fans(name):
            return Endpoint(
                path: "wap/api/account/fans/\(name)",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp)
                ]
            )
            
        case .navigation:
            return Endpoint(
                path: "wap/api/profile/navigation",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp)
                ]
            )
            
        // MARK: - 消息相关
        case let .conversations(page):
            return Endpoint(
                path: "wap/api/message/conversations",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp),
                    URLQueryItem(name: "page", value: String(page))
                ]
            )
            
        case let .notify(type, page):
            return Endpoint(
                path: "wap/api/notify/\(type)/\(page)",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp)
                ]
            )
            
        case let .conversationMessages(speakerId, page):
            return Endpoint(
                path: "wap/api/message/\(speakerId)/messages/\(page)",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp)
                ]
            )
            
        case let .markConversationRead(speakerId):
            return Endpoint(
                path: "wap/api/message/read",
                method: .post,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp),
                    URLQueryItem(name: "speakId", value: speakerId)
                ]
            )
            
        // MARK: - 搜索相关
        case let .searchArticle(keyword, start, count, original, earliest, boards, status):
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "t", value: timestamp),
                URLQueryItem(name: "keyword", value: keyword),
                URLQueryItem(name: "count", value: String(count)),
                URLQueryItem(name: "start", value: String(start)),
                URLQueryItem(name: "original", value: original ? "true" : "false"),
                URLQueryItem(name: "status", value: String(status))
            ]
            
            if let earliest = earliest {
                queryItems.append(URLQueryItem(name: "earliest", value: earliest))
            }
            
            if let boards = boards {
                queryItems.append(URLQueryItem(name: "boards", value: boards))
            }
            
            return Endpoint(
                path: "wap/api/search/article",
                method: .get,
                queryItems: queryItems
            )
            
        // MARK: - 草稿相关
        case let .drafts(sort):
            return Endpoint(
                path: "wap/api/draft/drafts",
                method: .get,
                queryItems: [
                    URLQueryItem(name: "t", value: timestamp),
                    URLQueryItem(name: "sort", value: sort)
                ]
            )
        }
    }
}
