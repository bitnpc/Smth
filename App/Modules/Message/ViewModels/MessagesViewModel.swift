//
//  MessagesViewModel.swift
//  Smth
//
//  消息视图模型，管理会话列表和通知消息的状态
//  Created by tony
//

import Foundation

@MainActor
final class MessagesViewModel: ObservableObject {
    @Published private(set) var conversations: [Conversation] = []
    @Published private(set) var notifies: [Notify] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingPage = false
    @Published private(set) var errorMessage: String?
    
    // 存储 conversationId 到 InboxMessage 的映射
    private var lastMessagesMap: [String: InboxMessage] = [:]
    
    private let repository: MessageRepositoryProtocol
    private var conversationPaginationState = PaginationState<Conversation>()
    private var notifyPaginationState = PaginationState<Notify>()
    private let pageSize = 20
    private var currentCategory: MessageCategory = .inbox
    private var notifyType: Int {
        switch currentCategory {
        case .inbox: return 0
        case .mention: return 1
        case .reply: return 2
        case .like: return 3
        }
    }
    
    init(repository: MessageRepositoryProtocol = AppContainer.shared.resolve(MessageRepositoryProtocol.self)) {
        self.repository = repository
    }
    
    var currentItems: [AnyHashable] {
        switch currentCategory {
        case .inbox:
            return conversations
        default:
            return notifies
        }
    }
    
    // 根据 conversationId 获取最后一条消息
    func getLastMessage(for conversationId: String) -> InboxMessage? {
        return lastMessagesMap[conversationId]
    }
    
    func loadMessages(for category: MessageCategory) async {
        currentCategory = category
        await loadInitialPage()
    }
    
    func loadNextPageIfNeeded() async {
        guard !isLoadingPage else { return }
        await loadNextPage()
    }
    
    private func loadInitialPage() async {
        isLoading = true
        errorMessage = nil
        
        switch currentCategory {
        case .inbox:
            conversationPaginationState.reset()
            conversations = []
            lastMessagesMap.removeAll()
        default:
            notifyPaginationState.reset()
            notifies = []
        }
        
        defer {
            isLoading = false
        }
        
        await loadPage()
    }
    
    private func loadNextPage() async {
        isLoadingPage = true
        defer { isLoadingPage = false }
        await loadPage()
    }
    
    private func loadPage() async {
        switch currentCategory {
        case .inbox:
            await loadConversationsPage()
        default:
            await loadNotifyPage()
        }
    }
    
    private func loadConversationsPage() async {
        let originalState = conversationPaginationState
        guard let nextPage = conversationPaginationState.startLoadingNextPage() else { return }
        
        do {
            let inboxData = try await repository.fetchConversations(page: nextPage)
            conversationPaginationState.completeLoading(with: inboxData.conversations, pageSize: pageSize)
            conversations = conversationPaginationState.items
            
            // 建立 conversationId 到 lastMessage 的映射
            for message in inboxData.lastMessages {
                lastMessagesMap[message.conversationId] = message
            }
        } catch {
            errorMessage = error.localizedDescription
            conversationPaginationState = originalState
            conversations = originalState.items
        }
    }
    
    private func loadNotifyPage() async {
        let originalState = notifyPaginationState
        guard let nextPage = notifyPaginationState.startLoadingNextPage() else { return }
        
        do {
            // API 页码从 0 开始，PaginationState 从 1 开始
            let newItems = try await repository.fetchNotify(type: notifyType, page: nextPage - 1)
            notifyPaginationState.completeLoading(with: newItems, pageSize: pageSize)
            notifies = notifyPaginationState.items
        } catch {
            errorMessage = error.localizedDescription
            notifyPaginationState = originalState
            notifies = originalState.items
        }
    }
    
    func reset() {
        conversations = []
        notifies = []
        lastMessagesMap.removeAll()
        conversationPaginationState.reset()
        notifyPaginationState.reset()
        isLoading = false
        isLoadingPage = false
        errorMessage = nil
    }
}
