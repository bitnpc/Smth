//
//  SearchResult.swift
//  Smth
//
//  Search result models
//

import Foundation

// 搜索文章（包含高亮信息）
struct SearchArticle: Codable, Hashable, Identifiable {
    let id: String
    let subject: String // 包含HTML高亮标签
    let body: String
    let postTime: TimeInterval
    let account: Account?
    let accountId: String
    let topicId: String
    let boardId: String
    let board: Board?
    let topic: SearchTopic?
    let topicOrder: Int
    let size: Int
    let score: Int
    let status: Int
    
    // 可选字段
    let groupId: String?
    let renderType: Int?
    let replyId: String?
    let editTime: TimeInterval?
    let forbiddenLike: Bool?
    let forbiddenReply: Bool?
    let forbiddenShare: Bool?
    let fav: Bool?
    let isPublic: Bool?
    let country: String?
    let city: String?
    
    enum CodingKeys: String, CodingKey {
        case id, subject, body, postTime, account, accountId, topicId, boardId, board, topic
        case topicOrder, size, score, status, groupId, renderType, replyId, editTime
        case forbiddenLike, forbiddenReply, forbiddenShare, fav, country, city
        case isPublic = "public"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        subject = try container.decode(String.self, forKey: .subject)
        body = try container.decode(String.self, forKey: .body)
        postTime = try container.decode(TimeInterval.self, forKey: .postTime)
        account = try? container.decodeIfPresent(Account.self, forKey: .account)
        accountId = try container.decode(String.self, forKey: .accountId)
        topicId = try container.decode(String.self, forKey: .topicId)
        boardId = try container.decode(String.self, forKey: .boardId)
        board = try? container.decodeIfPresent(Board.self, forKey: .board)
        topic = try? container.decodeIfPresent(SearchTopic.self, forKey: .topic)
        topicOrder = try container.decode(Int.self, forKey: .topicOrder)
        size = try container.decode(Int.self, forKey: .size)
        score = try container.decode(Int.self, forKey: .score)
        status = try container.decode(Int.self, forKey: .status)
        
        // 可选字段
        groupId = try? container.decodeIfPresent(String.self, forKey: .groupId)
        renderType = try? container.decodeIfPresent(Int.self, forKey: .renderType)
        replyId = try? container.decodeIfPresent(String.self, forKey: .replyId)
        editTime = try? container.decodeIfPresent(TimeInterval.self, forKey: .editTime)
        forbiddenLike = try? container.decodeIfPresent(Bool.self, forKey: .forbiddenLike)
        forbiddenReply = try? container.decodeIfPresent(Bool.self, forKey: .forbiddenReply)
        forbiddenShare = try? container.decodeIfPresent(Bool.self, forKey: .forbiddenShare)
        fav = try? container.decodeIfPresent(Bool.self, forKey: .fav)
        isPublic = try? container.decodeIfPresent(Bool.self, forKey: .isPublic)
        country = try? container.decodeIfPresent(String.self, forKey: .country)
        city = try? container.decodeIfPresent(String.self, forKey: .city)
    }
    
    // 提取纯文本标题（去掉HTML标签）
    var plainSubject: String {
        subject.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    // 提取高亮后的标题（转换为AttributedString）
    var attributedSubject: AttributedString {
        var attributed = AttributedString(plainSubject)
        // 这里可以添加高亮逻辑，暂时返回纯文本
        return attributed
    }
    
    var postTimeString: String {
        let date = Date(timeIntervalSince1970: postTime / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
}

// 搜索话题
struct SearchTopic: Codable, Hashable {
    let id: String
    let subject: String
    let boardId: String
    let firstArticleId: String
    let lastArticleId: String
    let availables: Int
    let likeAvailables: Int
    let flushTime: TimeInterval
    let lastPostTime: TimeInterval
    let lastArticleOrder: Int
    let fav: Bool
    let status: Int
}

// 搜索结果数据
struct SearchData: Codable {
    let total: Int
    let size: Int
    let start: Int
    let articles: [SearchArticle]
}

// 搜索结果响应
struct SearchResponse: Codable {
    let code: Int
    let data: SearchData
    let message: String
    let kbsCode: Int
}

