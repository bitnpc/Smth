//
//  Draft.swift
//  Smth
//
//  草稿数据模型，定义草稿预览和草稿响应结构
//  Created by tony
//

import Foundation

struct DraftPreview: Codable, Hashable {
    let ext: String
    let privateUrl: String?
    let size: Int
    let name: String
    let uri: String
    let key: String
}

struct Draft: Codable, Hashable, Identifiable {
    let id: String
    let subject: String
    let updateTime: TimeInterval
    let body: String
    let token: String
    let accountId: String
    let createTime: TimeInterval
    let replyId: String
    let boardId: String
    let renderType: Int
    let account: Account
    let board: Board
    let previews: [DraftPreview]?
    
    enum CodingKeys: String, CodingKey {
        case id, subject, updateTime, body, token, accountId, createTime, replyId, boardId, renderType, account, board, previews
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        subject = try container.decode(String.self, forKey: .subject)
        // API 返回的时间戳是毫秒，需要转换为秒
        let updateTimeMs = try container.decode(TimeInterval.self, forKey: .updateTime)
        updateTime = updateTimeMs / 1000.0
        body = try container.decode(String.self, forKey: .body)
        token = try container.decode(String.self, forKey: .token)
        accountId = try container.decode(String.self, forKey: .accountId)
        let createTimeMs = try container.decode(TimeInterval.self, forKey: .createTime)
        createTime = createTimeMs / 1000.0
        replyId = try container.decode(String.self, forKey: .replyId)
        boardId = try container.decode(String.self, forKey: .boardId)
        renderType = try container.decode(Int.self, forKey: .renderType)
        account = try container.decode(Account.self, forKey: .account)
        board = try container.decode(Board.self, forKey: .board)
        previews = try? container.decodeIfPresent([DraftPreview].self, forKey: .previews)
    }
}

struct DraftResponse: Codable {
    let code: Int
    let data: [Draft]
    let message: String
    let kbsCode: Int
}

