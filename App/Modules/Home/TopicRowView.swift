//
//  TopicRowView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI

struct TopicRowView: View {
    @Environment(\.colorScheme) private var colorScheme

    let topic: Topic
    let isVisited: Bool

    init(topic: Topic, isVisited: Bool = false) {
        self.topic = topic
        self.isVisited = isVisited
    }

    private var boardTitle: String {
        topic.board?.title ?? "未知版面"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(topic.subject)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)

            HStack(alignment: .center, spacing: 18) {
                HStack(spacing: 6) {
                    Image(systemName: "text.bubble")
                    Text("\(topic.availables)")
                }
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    Image(systemName: "hand.thumbsup")
                    Text("\(topic.likeAvailables)")
                }
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)

                Spacer()

                Text(boardTitle)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(AppTheme.accentColor(for: colorScheme))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AppTheme.accentColor(for: colorScheme).opacity(0.12))
                    )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .fill(isVisited ? AppTheme.subduedSurface(for: colorScheme) : AppTheme.surfaceBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .stroke(
                    AppTheme.borderColor(for: colorScheme).opacity(isVisited ? 0.4 : 1.0),
                    lineWidth: 1
                )
        )
        .shadow(
            color: AppTheme.shadowColor(for: colorScheme).opacity(isVisited ? 0.08 : 0.16),
            radius: isVisited ? 10 : 14,
            y: isVisited ? 3 : 8
        )
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(topic.subject)，回复 \(topic.availables) 条，点赞 \(topic.likeAvailables) 次，所属版面 \(boardTitle)")
    }
}
