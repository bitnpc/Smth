//
//  DraftView.swift
//  Smth
//
//  Created as part of the draft feature implementation.
//

import SwiftUI

struct DraftView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = DraftViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.drafts, id: \.id) { draft in
                DraftRowView(draft: draft)
            }
            if viewModel.drafts.isEmpty {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                } else {
                    Text("暂无草稿")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear {
            Task {
                await viewModel.loadDraftsIfNeeded()
            }
        }
        .listStyle(.plain)
        .navigationTitle("我的草稿")
    }
}

struct DraftRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let draft: Draft
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(draft.subject)
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if !draft.body.isEmpty {
                        Text(draft.body)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    
                    HStack(spacing: 12) {
                        Label(draft.board.title, systemImage: "square.grid.2x2")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(formatDate(draft.updateTime))
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Spacer()
            }
            
            if let previews = draft.previews, !previews.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(previews, id: \.key) { preview in
                            if let url = URL(string: preview.privateUrl ?? "") {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                                        .fill(AppTheme.subduedSurface(for: colorScheme))
                                        .overlay {
                                            ProgressView()
                                        }
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(.vertical, 12)
    }
    
    private func formatDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
}

