//
//  MessageRepository.swift
//  Smth
//
//  消息相关的数据仓库，负责获取会话列表、通知消息、对话详情等
//  Created by tony
//

import Foundation

struct ConversationMessagesResult {
    let messages: [InboxMessage]
    let speaker: Account?
    let account: Account?
}

protocol MessageRepositoryProtocol {
    func fetchConversations(page: Int) async throws -> InboxData
    func fetchNotify(type: Int, page: Int) async throws -> [Notify]
    func fetchConversationMessages(speakerId: String, page: Int) async throws -> ConversationMessagesResult
    func markConversationRead(speakerId: String) async throws
}

struct MessageRepository: MessageRepositoryProtocol {
    private let apiService: APIService

    init(apiService: APIService) {
        self.apiService = apiService
    }

    func fetchConversations(page: Int) async throws -> InboxData {
        let endpoint = APIEndpoint.conversations(page: page).toEndpoint()
        let response: InboxResponse = try await apiService.request(endpoint)
        return response.data
    }

    func fetchNotify(type: Int, page: Int) async throws -> [Notify] {
        let endpoint = APIEndpoint.notify(type: type, page: page).toEndpoint()
        let response: NotifyResponse = try await apiService.request(endpoint)
        return response.data.notifies
    }

    func fetchConversationMessages(speakerId: String, page: Int) async throws -> ConversationMessagesResult {
        let endpoint = APIEndpoint.conversationMessages(speakerId: speakerId, page: page).toEndpoint()
        let response: ConversationMessagesResponse = try await apiService.request(endpoint)

        return ConversationMessagesResult(
            messages: response.data.messages,
            speaker: response.data.speaker,
            account: response.data.account
        )
    }

    func markConversationRead(speakerId: String) async throws {
        let endpoint = APIEndpoint.markConversationRead(speakerId: speakerId).toEndpoint()
        _ = try await apiService.requestData(endpoint)
    }
}

struct StubMessageRepository: MessageRepositoryProtocol {
    var conversations: (_ page: Int) async throws -> InboxData
    var notify: (_ type: Int, _ page: Int) async throws -> [Notify]
    var conversationMessages: (_ speakerId: String, _ page: Int) async throws -> ConversationMessagesResult
    var markRead: (_ speakerId: String) async throws -> Void

    init(
        conversations: @escaping (_ page: Int) async throws -> InboxData = { _ in
            InboxData(conversations: [], lastMessages: [], pager: nil)
        },
        notify: @escaping (_ type: Int, _ page: Int) async throws -> [Notify] = { _, _ in [] },
        conversationMessages: @escaping (_ speakerId: String, _ page: Int)
            async throws -> ConversationMessagesResult = { _, _ in
            ConversationMessagesResult(messages: [], speaker: nil, account: nil)
        },
        markRead: @escaping (_ speakerId: String) async throws -> Void = { _ in }
    ) {
        self.conversations = conversations
        self.notify = notify
        self.conversationMessages = conversationMessages
        self.markRead = markRead
    }

    func fetchConversations(page: Int) async throws -> InboxData {
        try await conversations(page)
    }

    func fetchNotify(type: Int, page: Int) async throws -> [Notify] {
        try await notify(type, page)
    }

    func fetchConversationMessages(speakerId: String, page: Int) async throws -> ConversationMessagesResult {
        try await conversationMessages(speakerId, page)
    }

    func markConversationRead(speakerId: String) async throws {
        try await markRead(speakerId)
    }
}
