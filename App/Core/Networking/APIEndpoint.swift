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
            return buildHotTopicsEndpoint(page: page, pageSize: pageSize, timestamp: timestamp)
        case .topTopics:
            return buildTopTopicsEndpoint(timestamp: timestamp)
        case let .channelTopic(boardID, page, pageSize):
            return buildChannelTopicEndpoint(boardID: boardID, page: page, pageSize: pageSize, timestamp: timestamp)
        case let .topicList(boardID, page, pageSize):
            return buildTopicListEndpoint(boardID: boardID, page: page, pageSize: pageSize, timestamp: timestamp)
        case let .topicDetail(topicID, page, sortType):
            return buildTopicDetailEndpoint(topicID: topicID, page: page, sortType: sortType, timestamp: timestamp)
        case let .myTopics(page):
            return buildMyTopicsEndpoint(page: page, timestamp: timestamp)
        case let .albumTopics(page, pageSize):
            return buildAlbumTopicsEndpoint(page: page, pageSize: pageSize, timestamp: timestamp)
            
        // MARK: - 版块相关
        case .allSections:
            return buildAllSectionsEndpoint(timestamp: timestamp)
        case let .boards(sectionID):
            return buildBoardsEndpoint(sectionID: sectionID, timestamp: timestamp)
        case .favoriteBoards:
            return buildFavoriteBoardsEndpoint(timestamp: timestamp)
        case let .favoriteTopics(sort, page, pageSize):
            return buildFavoriteTopicsEndpoint(sort: sort, page: page, pageSize: pageSize, timestamp: timestamp)
            
        // MARK: - 用户相关
        case .profile:
            return buildProfileEndpoint()
        case let .friends(name):
            return buildFriendsEndpoint(name: name, timestamp: timestamp)
        case let .fans(name):
            return buildFansEndpoint(name: name, timestamp: timestamp)
        case .navigation:
            return buildNavigationEndpoint(timestamp: timestamp)
            
        // MARK: - 消息相关
        case let .conversations(page):
            return buildConversationsEndpoint(page: page, timestamp: timestamp)
        case let .notify(type, page):
            return buildNotifyEndpoint(type: type, page: page, timestamp: timestamp)
        case let .conversationMessages(speakerId, page):
            return buildConversationMessagesEndpoint(speakerId: speakerId, page: page, timestamp: timestamp)
        case let .markConversationRead(speakerId):
            return buildMarkConversationReadEndpoint(speakerId: speakerId, timestamp: timestamp)
            
        // MARK: - 搜索相关
        case let .searchArticle(keyword, start, count, original, earliest, boards, status):
            return buildSearchArticleEndpoint(
                keyword: keyword,
                start: start,
                count: count,
                original: original,
                earliest: earliest,
                boards: boards,
                status: status,
                timestamp: timestamp
            )
            
        // MARK: - 草稿相关
        case let .drafts(sort):
            return buildDraftsEndpoint(sort: sort, timestamp: timestamp)
        }
    }
    
    // MARK: - 话题相关端点构建方法
    private func buildHotTopicsEndpoint(page: Int, pageSize: Int, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/hot/global",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(pageSize))
            ]
        )
    }
    
    private func buildTopTopicsEndpoint(timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/hot/ten",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp),
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "size", value: "20")
            ]
        )
    }
    
    private func buildChannelTopicEndpoint(boardID: String, page: Int, pageSize: Int, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/channel/loadTopics",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp),
                URLQueryItem(name: "channel", value: boardID),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(pageSize))
            ]
        )
    }
    
    private func buildTopicListEndpoint(boardID: String, page: Int, pageSize: Int, timestamp: String) -> Endpoint {
        Endpoint(
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
    }
    
    private func buildTopicDetailEndpoint(topicID: String, page: Int, sortType: SortType, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/topic/loadArticlesByMode/\(topicID)/\(sortType.rawValue)/\(page)/20",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp)
            ]
        )
    }
    
    private func buildMyTopicsEndpoint(page: Int, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/profile/myarticle",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp),
                URLQueryItem(name: "type", value: "0"),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "sort", value: "DESC")
            ]
        )
    }
    
    private func buildAlbumTopicsEndpoint(page: Int, pageSize: Int, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/album/load/global",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(pageSize))
            ]
        )
    }
    
    // MARK: - 版块相关端点构建方法
    private func buildAllSectionsEndpoint(timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/section/all",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp)
            ]
        )
    }
    
    private func buildBoardsEndpoint(sectionID: String, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/section/subs",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp),
                URLQueryItem(name: "id", value: sectionID)
            ]
        )
    }
    
    private func buildFavoriteBoardsEndpoint(timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/profile/fav/boards",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp)
            ]
        )
    }
    
    private func buildFavoriteTopicsEndpoint(sort: String, page: Int, pageSize: Int, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/profile/favTopic/\(sort)/\(page)/\(pageSize)",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp)
            ]
        )
    }
    
    // MARK: - 用户相关端点构建方法
    private func buildProfileEndpoint() -> Endpoint {
        Endpoint(
            path: "wap/api/profile",
            method: .post,
            queryItems: []
        )
    }
    
    private func buildFriendsEndpoint(name: String, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/account/friends/\(name)",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp)
            ]
        )
    }
    
    private func buildFansEndpoint(name: String, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/account/fans/\(name)",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp)
            ]
        )
    }
    
    private func buildNavigationEndpoint(timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/profile/navigation",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp)
            ]
        )
    }
    
    // MARK: - 消息相关端点构建方法
    private func buildConversationsEndpoint(page: Int, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/message/conversations",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp),
                URLQueryItem(name: "page", value: String(page))
            ]
        )
    }
    
    private func buildNotifyEndpoint(type: Int, page: Int, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/notify/\(type)/\(page)",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp)
            ]
        )
    }
    
    private func buildConversationMessagesEndpoint(speakerId: String, page: Int, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/message/\(speakerId)/messages/\(page)",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp)
            ]
        )
    }
    
    private func buildMarkConversationReadEndpoint(speakerId: String, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/message/read",
            method: .post,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp),
                URLQueryItem(name: "speakId", value: speakerId)
            ]
        )
    }
    
    // MARK: - 搜索相关端点构建方法
    private func buildSearchArticleEndpoint(
        keyword: String,
        start: Int,
        count: Int,
        original: Bool,
        earliest: String?,
        boards: String?,
        status: Int,
        timestamp: String
    ) -> Endpoint {
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
    }
    
    // MARK: - 草稿相关端点构建方法
    private func buildDraftsEndpoint(sort: String, timestamp: String) -> Endpoint {
        Endpoint(
            path: "wap/api/draft/drafts",
            method: .get,
            queryItems: [
                URLQueryItem(name: "t", value: timestamp),
                URLQueryItem(name: "sort", value: sort)
            ]
        )
    }
}
