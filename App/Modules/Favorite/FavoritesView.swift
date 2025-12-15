//
//  FavoritesView.swift
//  Smth
//
//  收藏页面视图，展示收藏的版块和话题
//  Created by tony
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var loginState: LoginState

    @State private var selection: FavoritesTab = .boards
    @State private var showProfileView = false
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var showLoginView = false

    var body: some View {
        Group {
            if loginState.isLoggedIn {
                ScrollView {
                    LazyVStack(spacing: AppTheme.verticalSpacing, pinnedViews: [.sectionHeaders]) {
                        Section {
                            Group {
                                switch selection {
                                case .boards:
                                    FavBoardList(viewModel: viewModel)
                                case .topics:
                                    FavTopicList(viewModel: viewModel)
                                }
                            }
                            .animation(.easeInOut(duration: 0.2), value: selection)
                        } header: {
                            segmentedControl
                        }
                    }
                }
            } else {
                loginPromptView
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
        .onChange(of: loginState.isLoggedIn) { _, newValue in
            handleLoginStateChange(isLoggedIn: newValue, forceReload: true)
        }
        .sheet(isPresented: $showLoginView) {
            LoginView(showLoginView: $showLoginView)
        }
        .toolbarTitleDisplayMode(.inlineLarge)
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showProfileView = true
                } label: {
                    Image(systemName: "person.crop.circle")
                }
            }
        }
        .sheet(isPresented: $showProfileView) {
            NavigationStack {
                ProfileView()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
#endif
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
        VStack {
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
        GuestPromptView(
            icon: "star.fill",
            title: "登录后可查看收藏内容",
            subtitle: "同步你的版面与主题收藏，随时掌握关注动态。",
            onLogin: {
                showLoginView = true
            }
        )
    }

    private func handleLoginStateChange(isLoggedIn: Bool, forceReload: Bool = false) {
        if isLoggedIn {
            Task {
                if forceReload {
                    await viewModel.loadFavoriteBoards()
                    await viewModel.loadInitialFavoriteTopics()
                } else {
                    await viewModel.loadFavoritesIfNeeded()
                }
            }
        } else {
            viewModel.reset()
        }
    }
}
