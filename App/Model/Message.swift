//
//  Message.swift
//  Smth
//
//  Message model for inbox and notifications
//

import Foundation

struct Message: Codable, Hashable, Identifiable {
    let id: String
    let title: String?
    let body: String
    let timestamp: TimeInterval?
    let account: Account?
    let topicId: String?
    let board: Board?
    
    var dateString: String {
        guard let timestamp = timestamp else { return "" }
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
}

// Inbox Message (收件箱中的最后消息)
struct InboxMessage: Codable, Hashable, Identifiable {
    let id: String
    let senderId: String
    let recipientId: String
    let conversationId: String
    let subject: String
    let body: String
    let size: Int
    let type: Int
    let status: Int
    let sendTime: TimeInterval
    
    var dateString: String {
        let date = Date(timeIntervalSince1970: sendTime / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
    
    // 从 body 中提取消息内容（去掉邮件头）
    var content: String {
        // body 包含邮件头，提取实际内容
        let lines = body.components(separatedBy: "\n")
        // 跳过邮件头，找到第一个空行后的内容
        var contentLines: [String] = []
        var foundEmptyLine = false
        for line in lines {
            if foundEmptyLine {
                contentLines.append(line)
            } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                foundEmptyLine = true
            }
        }
        return contentLines.joined(separator: "\n").trimmingCharacters(in: .whitespaces)
    }
}

// Conversation (收件箱对话)
struct Conversation: Codable, Hashable, Identifiable {
    let id: String
    let accountId: String
    let speakerId: String
    let firstTime: TimeInterval
    let lastTime: TimeInterval
    let unread: Int
    let items: Int
    let status: Int
    let speaker: Account?
    let account: Account?
    
    var dateString: String {
        let date = Date(timeIntervalSince1970: lastTime / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
    
    // 获取对话标题（优先使用对方的昵称）
    var title: String? {
        speaker?.nick ?? speaker?.name
    }
    
    // 未读数量
    var unreadCount: Int {
        unread
    }
}

struct MessageCollection: Codable {
    let messages: [Message]?
    let conversations: [Conversation]?
    let notifies: [Message]?
    
    enum CodingKeys: String, CodingKey {
        case messages, conversations, notifies
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 尝试从 data 字段解析
        if let dataContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data) {
            messages = try? dataContainer.decodeIfPresent([Message].self, forKey: .messages)
            conversations = try? dataContainer.decodeIfPresent([Conversation].self, forKey: .conversations)
            notifies = try? dataContainer.decodeIfPresent([Message].self, forKey: .notifies)
        } else {
            // 如果没有 data 字段，直接从根级别解析
            messages = try? container.decodeIfPresent([Message].self, forKey: .messages)
            conversations = try? container.decodeIfPresent([Conversation].self, forKey: .conversations)
            notifies = try? container.decodeIfPresent([Message].self, forKey: .notifies)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(messages, forKey: .messages)
        try container.encodeIfPresent(conversations, forKey: .conversations)
        try container.encodeIfPresent(notifies, forKey: .notifies)
    }
}

// Inbox Pager
struct InboxPager: Codable {
    let total: Int
    let size: Int
    let page: Int
    let items: Int
}

// Inbox Data
struct InboxData: Codable {
    let conversations: [Conversation]
    let lastMessages: [InboxMessage]
    let pager: InboxPager?
}

// Inbox Response
struct InboxResponse: Codable {
    let code: Int
    let data: InboxData
    let message: String
    let kbsCode: Int
}

// Notify (回复/点赞/@等通知)
struct Notify: Codable, Hashable, Identifiable {
    let id: String
    let type: Int // 1=@我的, 2=回复我的, 3=Like我的
    let subject: String
    let createTime: TimeInterval
    let transactorId: String
    let transactorName: String
    let transactorAvatar: String?
    let transactor: Account?
    let targetId: String
    let target: Article? // 被回复/点赞的消息
    let cause: Article? // 回复/点赞的消息
    let causeId: String
    let causeType: Int
    let targetType: Int
    let account: Account?
    let accountId: String
    let status: Int
    
    var dateString: String {
        let date = Date(timeIntervalSince1970: createTime / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
    
    // 获取操作者名称
    var actorName: String {
        transactor?.nick ?? transactor?.name ?? transactorName
    }
    
    // 获取版面信息
    var board: Board? {
        cause?.board ?? target?.board
    }
    
    // 获取话题ID
    var topicId: String? {
        cause?.topicId ?? target?.topicId
    }
}

// Notify Data
struct NotifyData: Codable {
    let notifies: [Notify]
    let pager: InboxPager?
}

// Notify Response
struct NotifyResponse: Codable {
    let code: Int
    let data: NotifyData
    let message: String
    let kbsCode: Int
}

// Conversation Messages Response
struct ConversationMessagesData: Codable {
    let messages: [InboxMessage]
    let pager: InboxPager?
    let speaker: Account?
    let account: Account?
}

struct ConversationMessagesResponse: Codable {
    let code: Int
    let data: ConversationMessagesData
    let message: String
    let kbsCode: Int
}

// Mark Read Response
struct MarkReadResponse: Codable {
    let code: Int
    let message: String
    let kbsCode: Int
}

struct MessageResponse: Codable {
    let data: MessageCollection?
    let messages: [Message]?
    let conversations: [Conversation]?
    let notifies: [Message]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 尝试解析 data 字段
        if let data = try? container.decodeIfPresent(MessageCollection.self, forKey: .data) {
            self.data = data
            self.messages = data.messages
            self.conversations = data.conversations
            self.notifies = data.notifies
        } else {
            // 如果没有 data 字段，尝试直接解析数组
            self.data = nil
            self.messages = try? container.decodeIfPresent([Message].self, forKey: .messages)
            self.conversations = try? container.decodeIfPresent([Conversation].self, forKey: .conversations)
            self.notifies = try? container.decodeIfPresent([Message].self, forKey: .notifies)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case data, messages, conversations, notifies
    }
}

