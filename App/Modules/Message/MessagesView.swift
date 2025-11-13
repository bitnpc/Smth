//
//  MessagesView.swift
//  Smth
//
//  Created by 仝超 on 2025/11/12.
//

import SwiftUI

struct MessagesView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var selection: MessageTab = .inbox

    var body: some View {
        VStack(spacing: AppTheme.verticalSpacing) {
            header

            ScrollView {
                LazyVStack(spacing: AppTheme.verticalSpacing) {
                    ForEach(1...12, id: \.self) { index in
                        messageCard(
                            title: "\(selection.title) · 消息 \(index)",
                            body: "这里展示示例消息内容，真实数据接入后可替换，可展示多行文字描述当前通知的具体信息。"
                        )
                    }
                }
                .padding(.vertical, AppTheme.verticalSpacing)
            }
        }
        .padding(.horizontal, AppTheme.verticalSpacing)
        .padding(.top, AppTheme.verticalSpacing)
        .smthScaffoldBackground()
        .tint(AppTheme.accentColor(for: colorScheme))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("消息中心")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))

            Picker("消息类型", selection: $selection) {
                ForEach(MessageTab.allCases, id: \.self) { tab in
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
    private func messageCard(title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: selection.iconName)
                .font(.system(size: 24, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(AppTheme.accentColor(for: colorScheme).opacity(0.14))
                )
                .foregroundStyle(AppTheme.accentColor(for: colorScheme))

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                Text(body)
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

    private enum MessageTab: CaseIterable {
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
    }
}

#Preview {
    MessagesView()
}
