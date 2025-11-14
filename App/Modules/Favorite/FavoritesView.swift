//
//  FavoritesView.swift
//  Smth
//
//  Created by 仝超 on 2025/11/12.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var loginState: LoginState

    @State private var selection: FavoritesTab = .boards
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var showLoginView = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.verticalSpacing, pinnedViews: [.sectionHeaders]) {
                Section {
                    Group {
                        if loginState.isLoggedIn {
                            switch selection {
                            case .boards:
                                FavBoardList(viewModel: viewModel)
                            case .topics:
                                FavTopicList(viewModel: viewModel)
                            }
                        } else {
                            loginPromptView
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: selection)
                } header: {
                    segmentedControl
                }
            }
        }
        .smthScaffoldBackground()
        .tint(AppTheme.accentColor(for: colorScheme))
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
        .onAppear {
            handleLoginStateChange(isLoggedIn: loginState.isLoggedIn)
        }
        .onChange(of: loginState.isLoggedIn) { oldValue, newValue in
            handleLoginStateChange(isLoggedIn: newValue, forceReload: true)
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

    private var segmentedControl: some View {
        return VStack() {
            Picker("收藏类型", selection: $selection) {
                ForEach(FavoritesTab.allCases, id: \.self) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                    .fill(AppTheme.subduedSurface(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                            .stroke(AppTheme.borderColor(for: colorScheme))
                    )
            )
        }
    }
    
    private var loginPromptView: some View {
        VStack(spacing: 18) {
            Image(systemName: "lock.shield")
                .font(.system(size: 42))
                .foregroundStyle(AppTheme.accentColor(for: colorScheme))
            VStack(spacing: 6) {
                Text("登录后可查看收藏内容")
                    .font(.system(.headline, design: .rounded))
                Text("同步你的版面与主题收藏，随时掌握关注动态。")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Button {
                showLoginView = true
            } label: {
                Text("立即登录")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 48)
        .padding(.horizontal, 36)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .smthSurfaceBackground()
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
