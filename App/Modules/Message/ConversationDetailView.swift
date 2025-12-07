//
//  ConversationDetailView.swift
//  Smth
//
//  Conversation detail view showing messages in a conversation.
//

import SwiftUI

struct ConversationDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let conversation: Conversation
    @StateObject private var viewModel: ConversationDetailViewModel
    
    // 当前用户的 ID
    private var currentUserId: String {
        viewModel.currentUser?.id ?? conversation.accountId
    }
    
    // 对方用户的 ID
    private var speakerId: String {
        viewModel.speaker?.id ?? conversation.speakerId
    }
    
    @MainActor
    init(conversation: Conversation, viewModel: ConversationDetailViewModel? = nil) {
        self.conversation = conversation
        if let viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(wrappedValue: ConversationDetailViewModel(
                speakerId: conversation.speakerId
            ))
        }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("重试") {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if viewModel.messages.isEmpty {
                Text("暂无消息")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                messagesListView
            }
        }
        .smthScaffoldBackground()
        .tint(AppTheme.accentColor(for: colorScheme))
        .navigationTitle(viewModel.speaker?.nick ?? viewModel.speaker?.name ?? conversation.speaker?.nick ?? conversation.speaker?.name ?? "对话")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.loadInitialIfNeeded()
            }
        }
    }
    
    private var messagesListView: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                        MessageRowView(
                            message: message,
                            isCurrentUser: message.senderId == currentUserId,
                            currentUserAvatarUrl: viewModel.currentUser?.avatarUrl ?? conversation.account?.avatarUrl,
                            speakerAvatarUrl: viewModel.speaker?.avatarUrl ?? conversation.speaker?.avatarUrl,
                            maxBubbleWidth: geometry.size.width * 0.75
                        )
                            .onAppear {
                                // 当滚动到倒数第5个时加载下一页
                                if index == viewModel.messages.count - 5 {
                                    Task {
                                        await viewModel.loadNextPageIfNeeded()
                                    }
                                }
                            }
                    }
                    
                    if viewModel.isLoadingPage {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }
}

// 消息行视图
struct MessageRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let message: InboxMessage
    let isCurrentUser: Bool
    let currentUserAvatarUrl: String?
    let speakerAvatarUrl: String?
    let maxBubbleWidth: CGFloat
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !isCurrentUser {
                // 对方消息：头像在左边
                CachedAsyncImagePhase(url: URL(string: speakerAvatarUrl ?? "")) { phase in
                    switch phase {
                    case .empty, .failure:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    @unknown default:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppTheme.borderColor(for: colorScheme).opacity(0.2), lineWidth: 0.5)
                )
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 6) {
                // 消息内容气泡
                Text(message.content)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(isCurrentUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(isCurrentUser ? AppTheme.accentColor(for: colorScheme) : AppTheme.surfaceBackground(for: colorScheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isCurrentUser ? Color.clear : AppTheme.borderColor(for: colorScheme).opacity(0.3), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(isCurrentUser ? 0.1 : 0.05), radius: 2, x: 0, y: 1)
                
                // 时间
                Text(message.dateString)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: maxBubbleWidth, alignment: isCurrentUser ? .trailing : .leading)
            
            if isCurrentUser {
                // 当前用户消息：头像在右边
                CachedAsyncImagePhase(url: URL(string: currentUserAvatarUrl ?? "")) { phase in
                    switch phase {
                    case .empty, .failure:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    @unknown default:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppTheme.borderColor(for: colorScheme).opacity(0.2), lineWidth: 0.5)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
}

