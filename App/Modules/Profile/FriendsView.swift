//
//  FriendsView.swift
//  Smth
//
//  Created as part of the friends feature implementation.
//

import SwiftUI

struct FriendsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var loginState: LoginState
    
    let userName: String
    @StateObject private var viewModel: FriendsViewModel
    
    init(userName: String) {
        self.userName = userName
        _viewModel = StateObject(wrappedValue: FriendsViewModel(userName: userName))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.friends, id: \.id) { friend in
                NavigationLink(value: friend.friend) {
                    FriendRowView(account: friend.friend)
                }
            }
            if viewModel.friends.isEmpty {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                } else {
                    Text("暂无关注")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear {
            Task {
                await viewModel.loadFriendsIfNeeded()
            }
        }
        .listStyle(.plain)
        .navigationTitle("我的关注")
        .navigationDestination(for: Account.self) { account in
            ProfileDetail(account: account)
        }
    }
}

struct FriendRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let account: Account
    
    var body: some View {
        HStack(spacing: 16) {
            CachedAsyncImage(url: URL(string: account.avatarUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(AppTheme.borderColor(for: colorScheme), lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(account.name)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    if !account.nick.isEmpty && account.nick != account.name {
                        Text("昵称：\(account.nick)")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    
                    if let level = account.level {
                        Label("Lv.\(level)", systemImage: "star.fill")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(AppTheme.accentColor(for: colorScheme))
                    }
                }
                
                if !account.levelTitle.isEmpty {
                    Text(account.levelTitle)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

