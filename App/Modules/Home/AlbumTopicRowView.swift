//
//  AlbumTopicRowView.swift
//  Smth
//
//  图览话题行视图组件，展示图片和标题，图片占据大部分空间
//  Created by tony
//

import SwiftUI

struct AlbumTopicRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let topic: Topic
    let isVisited: Bool
    
    init(topic: Topic, isVisited: Bool = false) {
        self.topic = topic
        self.isVisited = isVisited
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
        VStack(alignment: .leading, spacing: 0) {
            // 图片部分 - 占据大部分空间
            if let attachment = firstImageAttachment,
               let ks3Url = attachment.ks3Url,
               let imageUrl = URL(string: ks3Url) {
                CachedAsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                                .tint(AppTheme.accentColor(for: colorScheme))
                        )
                }
                .frame(height: 280)
                .clipped()
            } else {
                // 如果没有图片，显示占位符
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 280)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("暂无图片")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    )
            }
            
            // 标题部分 - 在底部
            VStack(alignment: .leading, spacing: 8) {
                Text(topic.subject)
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, AppTheme.compactSpacing)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Rectangle()
                    .fill(AppTheme.surfaceBackground(for: colorScheme))
            )
        }
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
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .shadow(
            color: AppTheme.shadowColor(for: colorScheme).opacity(isVisited ? 0.08 : 0.16),
            radius: isVisited ? 10 : 14,
            y: isVisited ? 3 : 8
        )
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(topic.subject)")
    }
}

