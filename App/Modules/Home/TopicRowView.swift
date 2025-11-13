//
//  TopicRowView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct TopicRowView: View {
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
        VStack(alignment: .leading, spacing: 8) {
            Text(topic.subject)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Label("\(topic.availables)", systemImage: "text.bubble")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label("\(topic.likeAvailables)", systemImage: "hand.thumbsup")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(boardTitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var background: some View {
        Group {
            if isVisited {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(visitedBackgroundColor)
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(cardBackgroundColor)
            }
        }
    }

    private var cardBackgroundColor: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(uiColor: .secondarySystemBackground)
        #endif
    }

    private var visitedBackgroundColor: Color {
        #if os(macOS)
        return Color(nsColor: .controlHighlightColor)
        #else
        return Color(uiColor: .systemGray5)
        #endif
    }

    private var borderColor: Color {
        #if os(macOS)
        return Color(nsColor: .separatorColor).opacity(0.4)
        #else
        return Color(uiColor: .separator).opacity(0.4)
        #endif
    }
}
