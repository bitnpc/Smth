//
//  RefreshableListView.swift
//  Smth
//
//  Created by tony on 2024/3/21.
//

import SwiftUI

struct RefreshableListView<Item, Content: View>: View where Item: Identifiable {
    
    var items: [Item]
    var isRefreshing: Bool
    var onRefresh: () -> Void
    var isLoading: Bool
    var loadMore: (() -> Void)?
    var content: (Item) -> Content

    init(items: [Item], 
         isRefreshing: Bool,
         onRefresh: @escaping () -> Void,
         isLoading: Bool,
         loadMore: (() -> Void)? = nil,
         @ViewBuilder content: @escaping (Item) -> Content)
    {
        self.items = items
        self.isRefreshing = isRefreshing
        self.onRefresh = onRefresh
        self.isLoading = isLoading
        self.loadMore = loadMore
        self.content = content
    }

    var body: some View {
        List {
            ForEach(items) { item in
                self.content(item)
            }
            HStack(content: {
                Spacer()
                ProgressView().frame(height: 50)
                    .onAppear(perform: {
                        loadMore?()
                    })
                Spacer()
            })
        }
        .refreshable {
            onRefresh()
        }
    }
}

//#Preview {
//    RefreshableListView()
//}
