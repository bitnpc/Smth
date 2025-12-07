//
//  SearchViewModel.swift
//  Smth
//
//  Manages search state and results.
//

import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published private(set) var articles: [SearchArticle] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var total: Int = 0
    @Published private(set) var hasMore: Bool = false
    
    private let repository: SearchRepositoryProtocol
    private var currentKeyword: String = ""
    private var currentStart: Int = 0
    private let pageSize = 20
    
    init(repository: SearchRepositoryProtocol = SearchRepository()) {
        self.repository = repository
    }
    
    func search(keyword: String, original: Bool = true, earliest: String? = nil, boards: String? = nil, status: Int = 0) async {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        currentKeyword = keyword
        currentStart = 0
        isLoading = true
        errorMessage = nil
        articles = []
        
        defer {
            isLoading = false
        }
        
        do {
            let result = try await repository.searchArticles(
                keyword: keyword,
                start: currentStart,
                count: pageSize,
                original: original,
                earliest: earliest,
                boards: boards,
                status: status
            )
            
            articles = result.articles
            total = result.total
            currentStart = result.start + result.articles.count
            hasMore = currentStart < total
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadMore(original: Bool = true, earliest: String? = nil, boards: String? = nil, status: Int = 0) async {
        guard !isLoadingMore && hasMore && !currentKeyword.isEmpty else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        do {
            let result = try await repository.searchArticles(
                keyword: currentKeyword,
                start: currentStart,
                count: pageSize,
                original: original,
                earliest: earliest,
                boards: boards,
                status: status
            )
            
            articles.append(contentsOf: result.articles)
            currentStart = result.start + result.articles.count
            hasMore = currentStart < total
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func reset() {
        articles = []
        isLoading = false
        isLoadingMore = false
        errorMessage = nil
        total = 0
        hasMore = false
        currentKeyword = ""
        currentStart = 0
    }
}

