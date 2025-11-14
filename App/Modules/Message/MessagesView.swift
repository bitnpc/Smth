//
//  MessagesView.swift
//  Smth
//
//  Created by 仝超 on 2025/11/12.
//

import SwiftUI

struct MessagesView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var selection: MessageCategory
    private let onMessageSelected: ((MessagePreview) -> Void)?

    init(initialCategory: MessageCategory = .inbox, onMessageSelected: ((MessagePreview) -> Void)? = nil) {
        _selection = State(initialValue: initialCategory)
        self.onMessageSelected = onMessageSelected
    }

    var body: some View {
        VStack(spacing: AppTheme.verticalSpacing) {
            ScrollView {
                LazyVStack(spacing: AppTheme.verticalSpacing, pinnedViews: [.sectionHeaders]) {
                    Section {
                        ForEach(messages) { message in
                            if let onMessageSelected {
                                Button {
                                    onMessageSelected(message)
                                } label: {
                                    messageCard(for: message)
                                }
                                .buttonStyle(.plain)
                            } else {
                                messageCard(for: message)
                            }
                        }
                    } header: {
                        header
                    }
                }
            }
        }
        .smthScaffoldBackground()
        .tint(AppTheme.accentColor(for: colorScheme))
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

    private var messages: [MessagePreview] {
        (1...12).map { index in
            MessagePreview(
                title: "\(selection.title) · 消息 \(index)",
                body: "这里展示示例消息内容，真实数据接入后可替换，可展示多行文字描述当前通知的具体信息。",
                category: selection,
                timestamp: Date()
            )
        }
    }

    @ViewBuilder
    private func messageCard(for message: MessagePreview) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: message.category.iconName)
                .font(.system(size: 24, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(AppTheme.accentColor(for: colorScheme).opacity(0.14))
                )
                .foregroundStyle(AppTheme.accentColor(for: colorScheme))

            VStack(alignment: .leading, spacing: 8) {
                Text(message.title)
                    .font(.system(.headline, design: .rounded))
                Text(message.body)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, AppTheme.verticalSpacing)
        .smthSurfaceBackground()
    }
}

#Preview {
    MessagesView()
}

enum MessageCategory: CaseIterable, Hashable {
    case inbox
    case reply
    case like
    case mention

    var title: String {
        switch self {
        case .inbox: return "收件箱"
        case .reply: return "回复我的"
        case .like: return "Like我的"
        case .mention: return "@我的"
        }
    }

    var iconName: String {
        switch self {
        case .inbox: return "envelope.open"
        case .reply: return "arrowshape.turn.up.left"
        case .like: return "hand.thumbsup.fill"
        case .mention: return "at"
        }
    }

    var identifier: String {
        switch self {
        case .inbox: return "inbox"
        case .reply: return "reply"
        case .like: return "like"
        case .mention: return "mention"
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
