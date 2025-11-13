//
//  PaginationState.swift
//  Smth
//
//  Created for improved pagination handling.
//

import Foundation

struct PaginationState<Item: Identifiable & Hashable> {
    private(set) var items: [Item] = []
    private(set) var currentPage: Int = 0
    private(set) var isLoadingPage = false
    private(set) var canLoadMorePages = true

    mutating func reset() {
        items = []
        currentPage = 0
        isLoadingPage = false
        canLoadMorePages = true
    }

    mutating func startLoadingNextPage() -> Int? {
        guard !isLoadingPage, canLoadMorePages else {
            return nil
        }
        isLoadingPage = true
        currentPage += 1
        return currentPage
    }

    mutating func completeLoading(with newItems: [Item], pageSize: Int) {
        items.append(contentsOf: newItems)
        isLoadingPage = false
        canLoadMorePages = newItems.count != 0
    }
}


