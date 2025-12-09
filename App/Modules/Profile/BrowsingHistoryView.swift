//
//  BrowsingHistoryView.swift
//  Smth
//
//  浏览历史页面视图，展示用户浏览过的帖子历史
//  Created by tony
//

import SwiftUI

struct BrowsingHistoryView: View {
    @EnvironmentObject private var browsingHistory: BrowsingHistoryStore

    var body: some View {
        List {
            if browsingHistory.entries.isEmpty {
                ContentUnavailableView(
                    "暂无浏览记录",
                    systemImage: "clock",
                    description: Text("浏览帖子后会在这里展示最近的记录。")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(browsingHistory.entries) { entry in
                    NavigationLink {
                        TopicDetailView(topicID: entry.id)
                    } label: {
                        HistoryRow(entry: entry)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
        .navigationTitle("浏览历史")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("清空") {
                    browsingHistory.clear()
                }
                .disabled(browsingHistory.entries.isEmpty)
            }
        }
    }
}

private struct HistoryRow: View {
    let entry: TopicHistoryEntry
    private let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh-Hans")
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.subject)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(2)
            HStack(spacing: 8) {
                if let boardTitle = entry.boardTitle {
                    Label(boardTitle, systemImage: "rectangle.3.group")
                        .font(.caption)
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(relativeTimeText(for: entry.lastVisitedAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func relativeTimeText(for date: Date) -> String {
        dateFormatter.localizedString(for: date, relativeTo: Date())
    }
}


