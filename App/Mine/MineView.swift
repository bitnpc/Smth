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
        NavigationStack {
            List {
                NavigationLink (value: "profile") {
                    HStack (alignment: .center) {
                        AsyncImage(url: URL.init(string: dataSource.profile.account.avatarUrl)) { image in
                            image.resizable()
                                .frame(maxWidth: 80, maxHeight: 80)
                                .cornerRadius(40)
                        } placeholder: {
                            Image(systemName: "person.circle").resizable().frame(width: 80, height: 80)
                        }
                        VStack (alignment: .leading) {
                            Text(dataSource.profile.account.name)
                            Spacer()
                            HStack {
                                Text(dataSource.profile.title).font(.caption).foregroundColor(.gray)
                                Text(dataSource.profile.account.levelTitle).font(.caption).foregroundColor(.gray)
                            }
                            Spacer()
                            Text("昵称: \(dataSource.profile.account.nick)").font(.caption).foregroundColor(.gray)
                        }.frame(height: 60)
                            .padding(8)
                    }
                }
                Section {
                    NavigationLink (value: "myTopic") {
                        Text("文章")
                    }
                    
                    Text("草稿")
                    Text("收藏")
                }
                Section() {
                    Text("关注")
                    Text("粉丝")
                }
                Section() {
                    Text("浏览历史")
                }
                Section() {
                    Button("登录") {
                        showLoginView = true
                    }.sheet(isPresented: $showLoginView) {
                        LoginView(showLoginView: $showLoginView)
                    }
                }
            }
            .onAppear() {
                Task {
                    await dataSource.fetchProfile()
                }
            }
            .navigationTitle("我的")
            .navigationDestination(for: String.self) { string in
                if string == "profile" {
                    ProfileView(account: dataSource.profile.account)
                }else if string == "myTopic" {
                    MyTopicView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction, content: {
                    NavigationLink(destination: SettingView()) {
                        Image(systemName: "gearshape")
                    }
                })
            }
        }
    }
}
