//
//  ProfileView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var loginState: LoginState
    @State private var showLoginView = false
    @StateObject private var viewModel = ProfileViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                if loginState.isLoggedIn {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.secondary)
                    }
                }

                profileHeader

                if loginState.isLoggedIn {
                    Section {
                        NavigationLink(value: ProfileDestination.myTopic) {
                            Text("文章")
                        }
                        
                        Text("草稿")
                        Text("收藏")
                    }
                    Section() {
                        Text("关注")
                        Text("粉丝")
                    }
                    Section {
                        NavigationLink(value: ProfileDestination.history) {
                            Text("浏览历史")
                        }
                    }
                } else {
                    Section {
                        Text("登录后可查看完整资料和功能")
                            .foregroundStyle(.secondary)
                        Button("立即登录") {
                            showLoginView = true
                        }
                    }
                }
            }
            .onAppear() {
                handleLoginStateChange(isLoggedIn: loginState.isLoggedIn)
            }
            .onChange(of: loginState.isLoggedIn) { isLoggedIn in
                handleLoginStateChange(isLoggedIn: isLoggedIn, forceReload: true)
            }
            .navigationTitle("我的")
            .navigationDestination(for: ProfileDestination.self) { destination in
                switch destination {
                case let .profile(account):
                    ProfileDetail(account: account)
                case .myTopic:
                    MyTopicView()
                case .settings:
                    SettingView()
                case .history:
                    BrowsingHistoryView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction, content: {
                    NavigationLink(value: ProfileDestination.settings) {
                        Image(systemName: "gearshape")
                    }
                })
            }
            .sheet(isPresented: $showLoginView) {
                LoginView(showLoginView: $showLoginView)
            }
        }
    }

    private var profileHeader: some View {
        Group {
            if loginState.isLoggedIn {
                NavigationLink(value: ProfileDestination.profile(viewModel.profile.account)) {
                    profileRow
                }
            } else {
                Button {
                    showLoginView = true
                } label: {
                    profileRow
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var profileRow: some View {
        HStack (alignment: .center) {
            AsyncImage(url: URL(string: viewModel.profile.account.avatarUrl)) { image in
                image.resizable()
                    .frame(maxWidth: 80, maxHeight: 80)
                    .cornerRadius(40)
            } placeholder: {
                Image(systemName: "person.circle").resizable().frame(width: 80, height: 80)
            }
            VStack (alignment: .leading) {
                Text(viewModel.profile.account.name)
                Spacer()
                HStack {
                    Text(viewModel.profile.title).font(.caption).foregroundColor(.gray)
                    Text(viewModel.profile.account.levelTitle).font(.caption).foregroundColor(.gray)
                }
                Spacer()
                Text("昵称: \(viewModel.profile.account.nick)").font(.caption).foregroundColor(.gray)
            }.frame(height: 60)
                .padding(8)
        }
    }

    private func handleLoginStateChange(isLoggedIn: Bool, forceReload: Bool = false) {
        if isLoggedIn {
            Task {
                if forceReload {
                    await viewModel.loadProfile()
                } else {
                    await viewModel.loadProfileIfNeeded()
                }
            }
        } else {
            viewModel.reset()
        }
    }
}

private enum ProfileDestination: Hashable {
    case profile(Account)
    case myTopic
    case settings
    case history
}

