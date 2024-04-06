//
//  SectionView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

enum Route: Hashable {
    case favBoardItem(FavBoardItem)
    case allSection
}

struct SectionView: View {
    
    @StateObject var dataSource = SectionDataSource()
    
    var body: some View {
        NavigationStack {
            List {
                if dataSource.favSections.isEmpty == false {
                    ForEach(dataSource.favSections) { favBoard in
                        Section(header: Text(favBoard.name.isEmpty ? "收藏版面" : favBoard.name)) {
                            ForEach(favBoard.items, id: \.self) { favBoardItem in
                                NavigationLink(value: Route.favBoardItem(favBoardItem)) {
                                    Text(favBoardItem.bid.title)
                                }
                            }
                        }
                    }
                }else {
                    Text("暂无收藏")
                }
            }
            .onAppear() {
                Task {
                    await dataSource.fetchFavSections()
                }
            }
            .listStyle(.plain)
            .navigationTitle("版面")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .favBoardItem(item):
                    TopicListView(board: item.bid)
                case .allSection:
                    AllSectionView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: Route.allSection) {
                        Image(systemName: "list.bullet.clipboard")
                    }
                }
            }
        }
        
    }
}
