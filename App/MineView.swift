//
//  MineView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct MineView: View {
    
    @State private var showLoginView = false
    @StateObject var dataSource = MineDataSource()

    var body: some View {
        List {
            HStack {
                AsyncImage(url: URL.init(string: dataSource.profile.account.avatarUrl)) { image in
                    image.resizable()
                        .frame(maxWidth: 80, maxHeight: 80)
                        .cornerRadius(40)
                } placeholder: {
                    Image(systemName: "photo")
                }
                VStack (alignment: .leading) {
                    Text(dataSource.profile.account.name)
                    Text(dataSource.profile.title).font(.caption).foregroundColor(.gray)
                    Text("昵称: \(dataSource.profile.account.nick)").font(.caption).foregroundColor(.gray)
                }
            }
            Text("浏览历史")
            Text("我的收藏")
            Text("我的文章")
            Text("我的草稿")
        }
        .onAppear() {
            Task {
                await dataSource.fetchProfile()
            }
        }
        .listStyle(.plain)
        .navigationTitle("我的")
    }
}
