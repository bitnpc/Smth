//
//  TopicContentRowView.swift
//  Smth
//
//  话题内容行视图组件，展示话题的详细内容
//  Created by tony
//

import SwiftUI

struct TopicContentRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var layoutSettings: LayoutSettings

    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(article.subject)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(.primary)
                .lineSpacing(6)

            HStack(alignment: .center, spacing: 14) {
                CachedAsyncImage(url: URL(string: article.account!.avatarUrl)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(article.account!.name)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.primary)
                    Text(article.postTimeString)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text(article.content)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)
                .lineSpacing(8)

            if layoutSettings.showImages,
               let attachments = article.attachments, !attachments.isEmpty {
                ImageGroupView(attachments: attachments)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 26)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .fill(AppTheme.surfaceBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                .stroke(AppTheme.borderColor(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: AppTheme.shadowColor(for: colorScheme).opacity(0.16), radius: 18, y: 12)
    }
}
