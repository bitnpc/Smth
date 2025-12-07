//
//  MessageRepository.swift
//  Smth
//
//  Handles message and notification related network requests.
//

import Foundation
import Alamofire

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
    func fetchConversations(page: Int) async throws -> InboxData {
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let parameters = [
            "t": timestamp,
            "page": String(page)
        ]
        do {
            let response = try await AF.request(APIRouter.conversations(parameters: parameters))
                .serializingDecodable(InboxResponse.self)
                .value
            
            return response.data
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }
    
    func fetchNotify(type: Int, page: Int) async throws -> [Notify] {
        do {
            let response = try await AF.request(APIRouter.notify(type: type, page: page, parameters: [:]))
                .serializingDecodable(NotifyResponse.self)
                .value
            
            return response.data.notifies
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }
    
    func fetchConversationMessages(speakerId: String, page: Int) async throws -> ConversationMessagesResult {
        do {
            let response = try await AF.request(APIRouter.conversationMessages(speakerId: speakerId, page: page, parameters: [:]))
                .serializingDecodable(ConversationMessagesResponse.self)
                .value
            
            return ConversationMessagesResult(
                messages: response.data.messages,
                speaker: response.data.speaker,
                account: response.data.account
            )
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }
    
    func markConversationRead(speakerId: String) async throws {
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let parameters = [
            "t": timestamp,
            "speakId": speakerId
        ]
        do {
            _ = try await AF.request(APIRouter.markConversationRead(speakerId: speakerId, parameters: parameters))
                .serializingDecodable(MarkReadResponse.self)
                .value
        } catch {
            throw AppError.network(message: error.localizedDescription)
        }
    }
}

struct StubMessageRepository: MessageRepositoryProtocol {
    var conversations: (_ page: Int) async throws -> InboxData
    var notify: (_ type: Int, _ page: Int) async throws -> [Notify]
    var conversationMessages: (_ speakerId: String, _ page: Int) async throws -> ConversationMessagesResult
    var markRead: (_ speakerId: String) async throws -> Void
    
    init(
        conversations: @escaping (_ page: Int) async throws -> InboxData = { _ in InboxData(conversations: [], lastMessages: [], pager: nil) },
        notify: @escaping (_ type: Int, _ page: Int) async throws -> [Notify] = { _, _ in [] },
        conversationMessages: @escaping (_ speakerId: String, _ page: Int) async throws -> ConversationMessagesResult = { _, _ in ConversationMessagesResult(messages: [], speaker: nil, account: nil) },
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

