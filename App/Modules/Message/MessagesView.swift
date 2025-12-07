//
//  MessagesView.swift
//  Smth
//
//  Created by 仝超 on 2025/11/12.
//

import SwiftUI

struct MessagesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var loginState: LoginState

    @State private var selection: MessageCategory
    @State private var showProfileView = false
    @StateObject private var viewModel = MessagesViewModel()
    @State private var showLoginView = false

    init(initialCategory: MessageCategory = .inbox) {
        _selection = State(initialValue: initialCategory)
    }

    var body: some View {
        VStack(spacing: AppTheme.verticalSpacing) {
            if loginState.isLoggedIn {
                ScrollView {
                    LazyVStack(spacing: AppTheme.verticalSpacing, pinnedViews: [.sectionHeaders]) {
                        Section {
                            if viewModel.currentItems.isEmpty {
                                emptyState
                            } else {
                                ForEach(Array(viewModel.currentItems.enumerated()), id: \.element) { index, item in
                                    Group {
                                        if let conversation = item as? Conversation {
                                            NavigationLink(value: conversation) {
                                                messageCard(for: item, category: selection)
                                            }
                                            .buttonStyle(.plain)
                                        } else if let notify = item as? Notify {
                                            NavigationLink(value: notify) {
                                                messageCard(for: item, category: selection)
                                            }
                                            .buttonStyle(.plain)
                                        } else {
                                            messageCard(for: item, category: selection)
                                        }
                                    }
                                    .onAppear {
                                        // 当滚动到倒数第5个时加载下一页
                                        if index == viewModel.currentItems.count - 5 {
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
                        } header: {
                            header
                        }
                    }
                }
            } else {
                loginPromptView
            }
        }
        .smthScaffoldBackground()
        .tint(AppTheme.accentColor(for: colorScheme))
        .onAppear {
            handleLoginStateChange(isLoggedIn: loginState.isLoggedIn)
        }
        .onChange(of: loginState.isLoggedIn) { oldValue, newValue in
            handleLoginStateChange(isLoggedIn: newValue, forceReload: true)
        }
        .onChange(of: selection) { oldValue, newValue in
            Task {
                await viewModel.loadMessages(for: newValue)
            }
        }
        .sheet(isPresented: $showLoginView) {
            LoginView(showLoginView: $showLoginView)
        }
        .navigationDestination(for: Conversation.self) { conversation in
            ConversationDetailView(conversation: conversation)
        }
        .navigationDestination(for: Notify.self) { notify in
            if let topicId = notify.topicId {
                TopicDetailView(topicID: topicId)
            } else {
                Text("无法打开话题")
            }
        }
        .toolbarTitleDisplayMode(.inlineLarge)
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showProfileView = true
                }) {
                    Image(systemName: "person.crop.circle")
                }
            }
        }
        .sheet(isPresented: $showProfileView) {
            NavigationStack {
                ProfileView()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
#endif
    }

    private var header: some View {
        VStack() {
            Picker("消息类型", selection: $selection) {
                ForEach(MessageCategory.allCases, id: \.self) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                    .fill(AppTheme.subduedSurface(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                            .stroke(AppTheme.borderColor(for: colorScheme))
                    )
            )
        }
    }

    @ViewBuilder
    private func messageCard(for item: AnyHashable, category: MessageCategory) -> some View {
        HStack(alignment: .top, spacing: 16) {
            if let conversation = item as? Conversation {
                // 显示 speaker 的头像
                AsyncImage(url: URL(string: conversation.speaker?.avatarUrl ?? "")) { phase in
                    switch phase {
                    case .empty:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                    @unknown default:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            } else if let notify = item as? Notify {
                // 显示回复者的头像
                AsyncImage(url: URL(string: notify.transactor?.avatarUrl ?? notify.transactorAvatar ?? "")) { phase in
                    switch phase {
                    case .empty:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                    @unknown default:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            } else {
                // 其他类别使用图标
                Image(systemName: category.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(AppTheme.accentColor(for: colorScheme).opacity(0.14))
                    )
                    .foregroundStyle(AppTheme.accentColor(for: colorScheme))
            }

            VStack(alignment: .leading, spacing: 8) {
                if let conversation = item as? Conversation {
                    // 显示对方名称
                    HStack(spacing: 8) {
                        Text(conversation.speaker?.name ?? conversation.speaker?.nick ?? "未知用户")
                            .font(.system(.headline, design: .rounded))
                        
                        Spacer()
                        
                        // 显示消息数量
                        if conversation.items > 0 {
                            Text("\(conversation.items)条")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.subduedSurface(for: colorScheme))
                                )
                        }
                    }
                    
                    // 显示最后一条消息的 subject
                    if let lastMessage = viewModel.getLastMessage(for: conversation.id) {
                        Text(lastMessage.subject)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    // 显示未读数量
                    if conversation.unread > 0 {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(AppTheme.accentColor(for: colorScheme))
                                .frame(width: 6, height: 6)
                            Text("\(conversation.unread) 条未读")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(AppTheme.accentColor(for: colorScheme))
                        }
                    }
                    
                    // 显示最后时间
                    Text(conversation.dateString)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.tertiary)
                } else if let notify = item as? Notify {
                    // 显示操作者信息
                    HStack(spacing: 8) {
                        Text(notify.actorName)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // 显示版面信息
                        if let boardName = notify.board?.name {
                            Text(boardName)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(AppTheme.accentColor(for: colorScheme))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.accentColor(for: colorScheme).opacity(0.12))
                                )
                        }
                    }
                    
                    // 显示主题
                    Text(notify.subject)
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    // 显示回复内容预览
                    if let cause = notify.cause {
                        let previewText = cause.plainTextContent
                        if !previewText.isEmpty {
                            Text(previewText)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                                .padding(.top, 2)
                        }
                    } else if let target = notify.target {
                        let previewText = target.plainTextContent
                        if !previewText.isEmpty {
                            Text(previewText)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                                .padding(.top, 2)
                        }
                    }
                    
                    // 显示时间
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(.caption2, design: .rounded))
                        Text(notify.dateString)
                            .font(.system(.caption, design: .rounded))
                    }
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, AppTheme.verticalSpacing)
        .smthSurfaceBackground()
    }
    
    private var emptyState: some View {
        VStack(spacing: 10) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else if viewModel.isLoading {
                ProgressView()
            } else {
                Image(systemName: "envelope.open")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(AppTheme.accentColor(for: colorScheme))
                Text("暂无\(selection.title)")
                    .font(.system(.headline, design: .rounded))
                Text("有新消息时会在这里显示")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 56)
        .padding(.horizontal, 28)
        .smthSurfaceBackground(subdued: true)
    }
    
    private var loginPromptView: some View {
        VStack(spacing: 18) {
            Image(systemName: "lock.shield")
                .font(.system(size: 42))
                .foregroundStyle(AppTheme.accentColor(for: colorScheme))
            VStack(spacing: 6) {
                Text("登录后可查看消息")
                    .font(.system(.headline, design: .rounded))
                Text("同步你的消息和通知，随时掌握最新动态。")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Button {
                showLoginView = true
            } label: {
                Text("立即登录")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 48)
        .padding(.horizontal, 36)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .smthSurfaceBackground()
    }
    
    private func handleLoginStateChange(isLoggedIn: Bool, forceReload: Bool = false) {
        if isLoggedIn {
            Task {
                if forceReload {
                    await viewModel.loadMessages(for: selection)
                } else {
                    await viewModel.loadMessages(for: selection)
                }
            }
        } else {
            viewModel.reset()
        }
    }
}

#Preview {
    MessagesView()
}

enum MessageCategory: CaseIterable, Hashable {
    case inbox
    case mention
    case reply
    case like

    var title: String {
        switch self {
        case .inbox: return "收件箱"
        case .mention: return "@我的"
        case .reply: return "回复我的"
        case .like: return "Like我的"
        }
    }

    var iconName: String {
        switch self {
        case .inbox: return "envelope.open"
        case .mention: return "at"
        case .reply: return "arrowshape.turn.up.left"
        case .like: return "hand.thumbsup.fill"
        }
    }

    var identifier: String {
        switch self {
        case .inbox: return "inbox"
        case .mention: return "mention"
        case .reply: return "reply"
        case .like: return "like"
        }
    }
}

struct MessagePreview: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let body: String
    let category: MessageCategory
    let timestamp: Date
}
