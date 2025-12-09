//
//  TopicRowView.swift
//  Smth
//
//  话题行视图组件，展示单条话题信息
//  Created by tony
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

    private var firstImageAttachment: Attachment? {
        guard let attachments = topic.article?.attachments,
              !attachments.isEmpty else {
            return nil
        }
        // 查找第一个图片类型的附件
        return attachments.first { attachment in
            let type = attachment.type.lowercased()
            return type.contains("image") || 
                   type.contains("jpg") || 
                   type.contains("jpeg") || 
                   type.contains("png") || 
                   type.contains("gif") || 
                   type.contains("webp")
        } ?? attachments.first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(topic.subject)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if let article = topic.article {
                        Text(article.body)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if let attachment = firstImageAttachment,
                   let ks3Url = attachment.ks3Url,
                   let imageUrl = URL(string: ks3Url) {
                    CachedAsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }

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
        .padding(.vertical, AppTheme.compactSpacing)
        .padding(.horizontal, AppTheme.compactSpacing)
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
