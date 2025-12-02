//
//  ContentView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var loginState: LoginState
    @State private var selection: RootDestination? = .home
    #if os(macOS)
    private let homeBoards = Board.defaultBoard()
    @State private var sidebarSelection: SidebarSelection? = Board.defaultBoard().first.map { SidebarSelection.board($0) } ?? .home
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var searchText = ""
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var detailTopic: Topic?
    @State private var detailBoard: Board?
    @State private var detailMessage: MessagePreview?
    #endif

    var body: some View {
        Group {
            #if os(macOS)
            macSidebarLayout
            #else
            if horizontalSizeClass == .compact {
                tabLayout
            } else {
                sidebarLayout
            }
            #endif
        }
        .smthScaffoldBackground()
        .tint(AppTheme.accentColor(for: colorScheme))
    }

    private var tabLayout: some View {
        TabView(selection: Binding(get: {
            selection ?? .home
        }, set: {
            selection = $0
        })) {
            NavigationStack {
                HomeView()
                    .navigationTitle("首页")
            }
            .tabItem {
                Label("首页", systemImage: "house")
            }
            .tag(RootDestination.home)

            NavigationStack {
                FavoritesView()
                    .navigationTitle("收藏")
            }
            .tabItem {
                Label("收藏", systemImage: "heart")
            }
            .tag(RootDestination.favorites)

            NavigationStack {
                MessagesView()
                    .navigationTitle("消息")
            }
            .tabItem {
                Label("消息", systemImage: "bubble.left.and.bubble.right")
            }
            .tag(RootDestination.messages)
        }
        .background(Color.clear)
    }

    private var sidebarLayout: some View {
        NavigationSplitView {
            List(RootDestination.iOSCases, selection: $selection) { destination in
                Label(destination.title, systemImage: destination.iconName)
                    .tag(destination)
            }
            .listStyle(.sidebar)
            .navigationTitle("水木社区")
        } content: {
            EmptyView()
        } detail: {
            detailView(for: selection ?? .home)
        }
    }

    @ViewBuilder
    private func detailView(for destination: RootDestination) -> some View {
        switch destination {
        case .home:
            NavigationStack {
                HomeView()
            }
        case .favorites:
            NavigationStack {
                FavoritesView()
            }
        case .messages:
            NavigationStack {
                MessagesView()
            }
        case .mine:
            NavigationStack {
                ProfileView()
            }
        }
    }

    #if os(macOS)
    private var macSidebarLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            macSidebar
        } content: {
            macContentStack
        } detail: {
            macDetailPlaceholder
        }
        .onAppear {
            initializeSidebarIfNeeded()
            handleLoginStateChange(isLoggedIn: loginState.isLoggedIn)
        }
        .onChange(of: loginState.isLoggedIn) { _, newValue in
            handleLoginStateChange(isLoggedIn: newValue, forceReload: true)
        }
        .onChange(of: sidebarSelection) { _, _ in
            resetDetailSelection()
        }
    }

    private var macSidebar: some View {
        VStack(spacing: 0) {
            sidebarSearchBar
            List(selection: $sidebarSelection) {
                OutlineGroup(sidebarNodes, children: \.children) { node in
                    Label(node.title, systemImage: node.iconName)
                        .tag(node.selection)
                        .font(.system(.body, design: .rounded))
                        .padding(.vertical, 4)
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
                .padding(.horizontal, 12)

            profileSummaryButton
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
        .frame(minWidth: 260, maxHeight: .infinity)
    }

    private var macContentStack: some View {
        Group {
            if let selection = sidebarSelection {
                macContentView(for: selection)
            } else {
                PlaceholderView(symbolName: "sidebar.leading", title: "请选择左侧内容")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var macDetailPlaceholder: some View {
        macDetailView
    }

    @ViewBuilder
    private var macDetailView: some View {
        if let topic = detailTopic {
            TopicDetailView(topicID: topic.id)
        } else if let board = detailBoard {
            TopicListView(board: board, onTopicSelected: showTopicDetail)
        } else if let message = detailMessage {
            MessageDetailView(message: message)
        } else {
            PlaceholderView(symbolName: "doc.text.magnifyingglass", title: "选择一个内容查看详情")
        }
    }

    private var sidebarSearchBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("搜索版面或话题", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                    .fill(AppTheme.subduedSurface(for: colorScheme))
            )
            .padding(.horizontal, 12)

            Divider()
                .padding(.horizontal, 12)
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var profileSummaryButton: some View {
        Button {
            sidebarSelection = .profile
        } label: {
            HStack(spacing: 12) {
                ProfileAvatarView(imageURL: profileViewModel.profile.account.avatarUrl)
                VStack(alignment: .leading, spacing: 2) {
                    Text(loginState.isLoggedIn ? profileViewModel.profile.account.nick : "未登录")
                        .font(.system(.headline, design: .rounded))
                    Text("个人中心")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                    .fill(AppTheme.subduedSurface(for: colorScheme))
            )
        }
        .buttonStyle(.plain)
    }

    private var sidebarNodes: [SidebarNode] {
        [
            SidebarNode(
                id: "home",
                title: "首页",
                iconName: "house",
                selection: .home,
                children: filteredHomeBoards.map { board in
                    SidebarNode(
                        id: "home.board.\(board.id)",
                        title: board.title,
                        iconName: "text.justify.leading",
                        selection: .board(board)
                    )
                }
            ),
            SidebarNode(
                id: "favorites",
                title: "收藏",
                iconName: "heart",
                selection: .favorites,
                children: [
                    SidebarNode(id: "favorites.boards", title: "收藏版块", iconName: "square.grid.2x2", selection: .favoriteBoards),
                    SidebarNode(id: "favorites.topics", title: "收藏话题", iconName: "bookmark", selection: .favoriteTopics),
                ]
            ),
            SidebarNode(
                id: "messages",
                title: "消息",
                iconName: "bubble.left.and.bubble.right",
                selection: .messages,
                children: MessageCategory.allCases.map { category in
                    SidebarNode(
                        id: "messages.\(category.identifier)",
                        title: category.title,
                        iconName: category.iconName,
                        selection: .message(category)
                    )
                }
            )
        ]
    }

    private var filteredHomeBoards: [Board] {
        guard searchText.isEmpty == false else {
            return homeBoards
        }
        return homeBoards.filter { board in
            board.title.localizedCaseInsensitiveContains(searchText) ||
            board.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    @ViewBuilder
    private func macContentView(for selection: SidebarSelection) -> some View {
        switch selection {
        case .home:
            HomeView()
        case let .board(board):
            TopicListView(board: board, onTopicSelected: showTopicDetail)
        case .favorites:
            FavoritesColumnView(
                viewModel: favoritesViewModel,
                mode: .dashboard,
                onBoardSelected: showBoardDetail,
                onTopicSelected: showTopicDetail
            )
        case .favoriteBoards:
            FavoritesColumnView(
                viewModel: favoritesViewModel,
                mode: .boards,
                onBoardSelected: showBoardDetail,
                onTopicSelected: showTopicDetail
            )
        case .favoriteTopics:
            FavoritesColumnView(
                viewModel: favoritesViewModel,
                mode: .topics,
                onBoardSelected: showBoardDetail,
                onTopicSelected: showTopicDetail
            )
        case .messages:
            MessagesView(onMessageSelected: showMessageDetail)
        case let .message(category):
            MessagesView(initialCategory: category, onMessageSelected: showMessageDetail)
        case .profile:
            ProfileView()
        }
    }

    private func initializeSidebarIfNeeded() {
        if sidebarSelection == nil {
            sidebarSelection = homeBoards.first.map { SidebarSelection.board($0) } ?? .home
        }
    }

    private func handleLoginStateChange(isLoggedIn: Bool, forceReload: Bool = false) {
        if isLoggedIn {
            Task {
                if forceReload {
                    await favoritesViewModel.loadFavoriteBoards()
                    await favoritesViewModel.loadFavoriteTopics()
                    await profileViewModel.loadProfile()
                } else {
                    await favoritesViewModel.loadFavoritesIfNeeded()
                    await profileViewModel.loadProfileIfNeeded()
                }
            }
        } else {
            favoritesViewModel.reset()
            profileViewModel.reset()
        }
    }

    private func showTopicDetail(_ topic: Topic) {
        detailTopic = topic
        detailBoard = nil
        detailMessage = nil
    }

    private func showBoardDetail(_ board: Board) {
        detailBoard = board
        detailTopic = nil
        detailMessage = nil
    }

    private func showMessageDetail(_ message: MessagePreview) {
        detailMessage = message
        detailTopic = nil
        detailBoard = nil
    }

    private func resetDetailSelection() {
        detailTopic = nil
        detailBoard = nil
        detailMessage = nil
    }
    #endif
}

private enum RootDestination: String, CaseIterable, Hashable, Identifiable {
    case home
    case favorites
    case messages
    case mine

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "首页"
        case .favorites: return "收藏"
        case .messages: return "消息"
        case .mine: return "我的"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house"
        case .favorites: return "heart"
        case .messages: return "bubble.left.and.bubble.right"
        case .mine: return "person.circle"
        }
    }
    
    /// iOS 平台显示的 tab 列表（不包含"我的"）
    static var iOSCases: [RootDestination] {
        [.home, .favorites, .messages]
    }
}

#if os(macOS)
private enum SidebarSelection: Hashable {
    case home
    case board(Board)
    case favorites
    case favoriteBoards
    case favoriteTopics
    case messages
    case message(MessageCategory)
    case profile
}

private struct SidebarNode: Identifiable {
    let id: String
    let title: String
    let iconName: String
    let selection: SidebarSelection
    var children: [SidebarNode]? = nil
}

private enum FavoritesDisplayMode {
    case dashboard
    case boards
    case topics
}

private struct FavoritesColumnView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    let mode: FavoritesDisplayMode
    let onBoardSelected: ((Board) -> Void)?
    let onTopicSelected: ((Topic) -> Void)?

    @EnvironmentObject private var loginState: LoginState

    var body: some View {
        Group {
            if loginState.isLoggedIn {
                ScrollView {
                    VStack(spacing: AppTheme.verticalSpacing) {
                        if mode != .topics {
                            FavBoardList(viewModel: viewModel) { item in
                                onBoardSelected?(item.bid)
                            }
                        }
                        if mode != .boards {
                            FavTopicList(viewModel: viewModel, onTopicSelected: onTopicSelected)
                        }
                    }
                    .padding(.horizontal, AppTheme.verticalSpacing)
                    .padding(.top, AppTheme.verticalSpacing)
                }
            } else {
                FavoritesLoginPrompt()
            }
        }
        .smthScaffoldBackground()
    }
}

private struct FavoritesLoginPrompt: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "lock.shield")
                .font(.system(size: 42))
                .foregroundStyle(AppTheme.accentColor(for: colorScheme))
            Text("登录后可查看收藏内容")
                .font(.system(.headline, design: .rounded))
            Text("请先在个人中心完成登录，再回来查看收藏版块与话题。")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private struct ProfileAvatarView: View {
    @Environment(\.colorScheme) private var colorScheme
    let imageURL: String

    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.subduedSurface(for: colorScheme))
            if let url = URL(string: imageURL), imageURL.isEmpty == false {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholder
                    }
                }
                .clipShape(Circle())
            } else {
                placeholder
            }
        }
        .frame(width: 44, height: 44)
    }

    private var placeholder: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.secondary)
            .padding(4)
    }
}

private struct PlaceholderView: View {
    let symbolName: String
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: symbolName)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MessageDetailView: View {
    let message: MessagePreview
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: message.category.iconName)
                    .font(.system(size: 28, weight: .semibold))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(AppTheme.accentColor(for: colorScheme).opacity(0.15))
                    )
                    .foregroundStyle(AppTheme.accentColor(for: colorScheme))
                VStack(alignment: .leading, spacing: 6) {
                    Text(message.title)
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                    Text(message.timestamp, style: .time)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Text(message.body)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.primary)
                .lineSpacing(4)

            Spacer()
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
#endif
