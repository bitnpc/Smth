//
//  ConversationDetailViewModel.swift
//  Smth
//
//  会话详情视图模型，管理对话消息的加载和分页
//  Created by tony
//

import Foundation

@MainActor
final class ConversationDetailViewModel: ObservableObject {
    @Published private(set) var messages: [InboxMessage] = []
    @Published private(set) var speaker: Account?
    @Published private(set) var currentUser: Account?
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingPage = false
    @Published private(set) var errorMessage: String?
    
    private let repository: MessageRepositoryProtocol
    private let speakerId: String
    private var paginationState = PaginationState<InboxMessage>()
    private let pageSize = 20
    
    init(
        speakerId: String,
        repository: MessageRepositoryProtocol = AppContainer.shared.resolve(MessageRepositoryProtocol.self)
    ) {
        self.speakerId = speakerId
        self.repository = repository
    }
    
    func loadInitialIfNeeded() async {
        guard messages.isEmpty else { return }
        await loadInitialPage()
    }
    
    func loadNextPageIfNeeded() async {
        guard !isLoadingPage else { return }
        await loadNextPage()
    }
    
    private func loadInitialPage() async {
        isLoading = true
        errorMessage = nil
        paginationState.reset()
        messages = []
        defer {
            isLoading = false
        }
        
        // 同时加载消息和标记已读
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.loadPage()
            }
            group.addTask {
                do {
                    try await self.repository.markConversationRead(speakerId: self.speakerId)
                } catch {
                    // 标记已读失败不影响消息加载
                    print("标记已读失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadNextPage() async {
        isLoadingPage = true
        defer { isLoadingPage = false }
        await loadPage()
    }
    
    private func loadPage() async {
        let originalState = paginationState
        guard let nextPage = paginationState.startLoadingNextPage() else { return }
        
        do {
            // API 页码从 1 开始
            let response = try await repository.fetchConversationMessages(
                speakerId: speakerId,
                page: nextPage
            )
            paginationState.completeLoading(with: response.messages, pageSize: pageSize)
            messages = paginationState.items
            
            // 只在第一页时更新用户信息
            if nextPage == 1 {
                speaker = response.speaker
                currentUser = response.account
            }
        } catch {
            errorMessage = error.localizedDescription
            paginationState = originalState
            messages = originalState.items
        }
    }
    
    func refresh() async {
        await loadInitialPage()
    }
}
