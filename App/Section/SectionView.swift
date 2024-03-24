//
//  SectionView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct SectionView: View {
    
    @StateObject var dataSource = SectionDataSource()
    
    var body: some View {
        NavigationStack {
            List {
                if dataSource.favSections.isEmpty == false {
                    ForEach(dataSource.favSections) { favBoard in
                        Section(header: Text(favBoard.name.isEmpty ? "收藏版面" : favBoard.name)) {
                            ForEach(favBoard.items, id: \.self) { favBoardItem in
                                NavigationLink(value: favBoardItem) {
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
            .navigationDestination(for: FavBoardItem.self) { favBoardItem in
                TopicListView(board: favBoardItem.bid)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction, content: {
                    NavigationLink(destination: AllSectionView()) {
                        Image(systemName: "list.bullet.clipboard")
                    }
                })
            }
        }
        
    }
}
