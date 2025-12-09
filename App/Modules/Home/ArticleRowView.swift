//
//  ArticleRowView.swift
//  Smth
//
//  文章行视图组件，展示单条文章信息
//  Created by tony
//

import SwiftUI

struct ArticleRowView: View {
    @Environment(\.colorScheme) private var colorScheme

    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                CachedAsyncImage(url: URL(string: article.account!.avatarUrl)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(article.account!.name)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(.primary)
                    Text(article.postTimeString)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text(article.content)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)
                .lineSpacing(8)

            if !article.quoteContent.isEmpty {
                Text(article.quoteContent)
                    .font(.system(.footnote, design: .rounded))
                    .lineSpacing(6)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 12)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                            .fill(AppTheme.subduedSurface(for: colorScheme))
                    )
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .fill(AppTheme.surfaceBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .stroke(AppTheme.borderColor(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: AppTheme.shadowColor(for: colorScheme).opacity(0.09), radius: 12, y: 6)
    }
}
