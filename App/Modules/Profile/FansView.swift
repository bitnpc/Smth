//
//  FansView.swift
//  Smth
//
//  粉丝页面视图，展示用户粉丝列表
//  Created by tony
//

import SwiftUI

struct FansView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var loginState: LoginState
    
    let userName: String
    @StateObject private var viewModel: FansViewModel
    
    init(userName: String) {
        self.userName = userName
        _viewModel = StateObject(wrappedValue: FansViewModel(userName: userName))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.fans, id: \.id) { fan in
                NavigationLink(value: fan.friend) {
                    FriendRowView(account: fan.friend)
                }
            }
            if viewModel.fans.isEmpty {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                } else {
                    Text("暂无粉丝")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear {
            Task {
                await viewModel.loadFansIfNeeded()
            }
        }
        .listStyle(.plain)
        .navigationTitle("我的粉丝")
        .navigationDestination(for: Account.self) { account in
            ProfileDetail(account: account)
        }
    }
}
