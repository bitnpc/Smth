//
//  FavoritesView.swift
//  Smth
//
//  Created by 仝超 on 2025/11/12.
//

import SwiftUI

struct FavoritesView: View {
    
    @EnvironmentObject private var loginState: LoginState
    @State private var selection: FavoritesTab = .boards
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var showLoginView = false

    var body: some View {
        VStack(spacing: 0) {
            Picker("收藏类型", selection: $selection) {
                ForEach(FavoritesTab.allCases, id: \.self) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Group {
                if loginState.isLoggedIn {
                    switch selection {
                    case .boards:
                        FavBoardList(viewModel: viewModel)
                    case .topics:
                        FavTopicList(viewModel: viewModel)
                    }
                    
                }else {
                    loginPromptView
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selection)
            .navigationDestination(for: FavoriteRoute.self) { route in
                switch route {
                case let .favBoardItem(item):
                    TopicListView(board: item.bid)
                case let .favTopic(topic):
                    TopicDetailView(topicID: topic.id)
                case .allSection:
                    AllSectionView()
                }
            }
            .navigationDestination(for: SMSection.self) { section in
                BoardListView(section: section)
            }
            .navigationDestination(for: Topic.self) { topic in
                TopicDetailView(topicID: topic.id)
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onAppear() {
            handleLoginStateChange(isLoggedIn: loginState.isLoggedIn)
        }
        .onChange(of: loginState.isLoggedIn) { isLoggedIn in
            handleLoginStateChange(isLoggedIn: isLoggedIn, forceReload: true)
        }
        .sheet(isPresented: $showLoginView) {
            LoginView(showLoginView: $showLoginView)
        }
    }

    private enum FavoritesTab: CaseIterable {
        case boards
        case topics

        var title: String {
            switch self {
            case .boards: return "版面"
            case .topics: return "主题"
            }
        }
    }
    
    private var loginPromptView: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("登录后可查看收藏内容")
                .foregroundStyle(.secondary)
            Button {
                showLoginView = true
            } label: {
                Text("立即登录")
                    .font(.body)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.vertical, 48)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private func handleLoginStateChange(isLoggedIn: Bool, forceReload: Bool = false) {
        if isLoggedIn {
            Task {
                if forceReload {
                    await viewModel.loadFavoriteBoards()
                    await viewModel.loadFavoriteTopics()
                } else {
                    await viewModel.loadFavoritesIfNeeded()
                }
            }
        } else {
            viewModel.reset()
        }
    }
}

#Preview {
    FavoritesView()
}
