//
//  SearchView.swift
//  Smth
//
//  Search view for articles
//

import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            searchBar
            
            // 搜索结果
            if viewModel.isLoading && viewModel.articles.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                errorView(errorMessage)
            } else if viewModel.articles.isEmpty && !searchText.isEmpty {
                emptyState
            } else if !viewModel.articles.isEmpty {
                resultsList
            } else {
                placeholderView
            }
        }
        .smthScaffoldBackground()
        .tint(AppTheme.accentColor(for: colorScheme))
        .navigationTitle("搜索")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: String.self) { topicId in
            TopicDetailView(topicID: topicId)
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("搜索文章", text: $searchText)
                    .focused($isSearchFieldFocused)
                    .onSubmit {
                        performSearch()
                    }
                    .submitLabel(.search)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        viewModel.reset()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.surfaceBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.borderColor(for: colorScheme), lineWidth: 1)
            )
            
            Button {
                performSearch()
            } label: {
                Text("搜索")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(AppTheme.accentColor(for: colorScheme))
                    )
            }
            .disabled(searchText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, AppTheme.verticalSpacing)
        .padding(.vertical, 12)
        .background(AppTheme.subduedSurface(for: colorScheme))
    }
    
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.verticalSpacing) {
                // 结果统计
                if viewModel.total > 0 {
                    HStack {
                        Text("找到 \(viewModel.total) 条结果")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.verticalSpacing)
                    .padding(.top, 8)
                }
                
                // 文章列表
                ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                    NavigationLink(value: article.topicId) {
                        SearchArticleRowView(article: article)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        // 当滚动到倒数第5个时加载更多
                        if index == viewModel.articles.count - 5 && viewModel.hasMore {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    }
                }
                
                // 加载更多指示器
                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding()
                } else if viewModel.hasMore {
                    Button {
                        Task {
                            await viewModel.loadMore()
                        }
                    } label: {
                        Text("加载更多")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppTheme.accentColor(for: colorScheme))
                            .padding()
                    }
                }
            }
            .padding(.vertical, AppTheme.verticalSpacing)
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(AppTheme.accentColor(for: colorScheme).opacity(0.5))
            Text("搜索文章")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(AppTheme.accentColor(for: colorScheme).opacity(0.5))
            Text("未找到相关结果")
                .font(.system(.headline, design: .rounded))
            Text("请尝试其他关键词")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("重试") {
                performSearch()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearchFieldFocused = false
        Task {
            await viewModel.search(keyword: searchText)
        }
    }
}

// 搜索文章行视图
struct SearchArticleRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let article: SearchArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题（包含高亮）
            highlightText(article.subject)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .lineLimit(2)
            
            // 用户信息和版面
            HStack(spacing: 12) {
                // 用户头像
                CachedAsyncImagePhase(url: URL(string: article.account?.avatarUrl ?? "")) { phase in
                    switch phase {
                    case .empty, .failure:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    @unknown default:
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 20, height: 20)
                .clipShape(Circle())
                
                // 用户名
                if let account = article.account {
                    Text(account.nick ?? account.name)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 版面信息
                if let board = article.board {
                    Text(board.name)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppTheme.accentColor(for: colorScheme))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(AppTheme.accentColor(for: colorScheme).opacity(0.12))
                        )
                }
            }
            
            // 时间和回复数
            HStack(spacing: 8) {
                Text(article.postTimeString)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.tertiary)
                
                if let topic = article.topic, topic.availables > 0 {
                    Text("\(topic.availables) 回复")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, AppTheme.verticalSpacing)
        .smthSurfaceBackground()
    }
    
    // 高亮文本显示
    private func highlightText(_ htmlText: String) -> Text {
        let plainText = htmlText.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        var attributed = AttributedString(plainText)
        
        // 提取高亮关键词（从<span class="highlight">标签中）
        let pattern = "<span class=\"highlight\">([^<]+)</span>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsString = htmlText as NSString
            let matches = regex.matches(in: htmlText, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                if match.numberOfRanges > 1 {
                    let highlightRange = match.range(at: 1)
                    let highlightText = nsString.substring(with: highlightRange)
                    
                    // 在纯文本中找到对应的范围并高亮
                    if let range = attributed.range(of: highlightText) {
                        attributed[range].foregroundColor = AppTheme.accentColor(for: colorScheme)
                        attributed[range].backgroundColor = AppTheme.accentColor(for: colorScheme).opacity(0.15)
                    }
                }
            }
        }
        
        return Text(attributed)
    }
}

#Preview {
    SearchView()
}

