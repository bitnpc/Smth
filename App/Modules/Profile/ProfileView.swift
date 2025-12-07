//
//  ProfileView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var loginState: LoginState

    @State private var showLoginView = false
    @StateObject private var viewModel = ProfileViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: AppTheme.verticalSpacing) {
                    if loginState.isLoggedIn {
                        if let errorMessage = viewModel.errorMessage {
                            errorCard(errorMessage)
                        } else {
                            loggedInContent
                                .overlay(alignment: .top) {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .padding(.top, 8)
                                    }
                                }
                        }
                    } else {
                        guestCard
                    }
                }
                .padding(.horizontal, AppTheme.verticalSpacing)
                .padding(.vertical, AppTheme.verticalSpacing)
            }
            .smthScaffoldBackground()
            .tint(AppTheme.accentColor(for: colorScheme))
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
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(value: ProfileDestination.settings) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showLoginView) {
                LoginView(showLoginView: $showLoginView)
            }
            .onAppear {
                handleLoginStateChange(isLoggedIn: loginState.isLoggedIn)
            }
            .onChange(of: loginState.isLoggedIn) { oldValue, newValue in
                handleLoginStateChange(isLoggedIn: newValue, forceReload: true)
            }
        }
    }

    private var loggedInContent: some View {
        VStack(spacing: AppTheme.verticalSpacing) {
            NavigationLink(value: ProfileDestination.profile(viewModel.profile.account)) {
                profileHeaderCard
            }
            .buttonStyle(.plain)

            actionSection(title: "创作与收藏", rows: [
                .init(
                    title: "文章",
                    subtitle: "查看并管理你发布的所有主题帖",
                    icon: "doc.text.fill",
                    destination: .myTopic
                ),
                .init(
                    title: "草稿",
                    subtitle: "草稿箱功能即将上线",
                    icon: "tray.full",
                    destination: nil
                ),
                .init(
                    title: "收藏",
                    subtitle: "快速跳转到收藏列表",
                    icon: "heart.fill",
                    destination: nil
                )
            ])

            actionSection(title: "互动关系", rows: [
                .init(
                    title: "关注",
                    subtitle: "查看你关注的用户",
                    icon: "person.2.fill",
                    destination: nil
                ),
                .init(
                    title: "粉丝",
                    subtitle: "了解关注你的读者",
                    icon: "person.crop.circle.badge.plus",
                    destination: nil
                )
            ])

            actionSection(title: "浏览记录", rows: [
                .init(
                    title: "浏览历史",
                    subtitle: "回顾最近查看的主题与回复",
                    icon: "clock.arrow.circlepath",
                    destination: .history
                )
            ])
        }
    }

    private var profileHeaderCard: some View {
        HStack(alignment: .center, spacing: 20) {
            AsyncImage(url: URL(string: viewModel.profile.account.avatarUrl)) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(AppTheme.borderColor(for: colorScheme), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.profile.account.name)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundColor(.primary)
                HStack(spacing: 10) {
                    badge(text: viewModel.profile.title, systemImage: "star.fill")
                    badge(text: viewModel.profile.account.levelTitle, systemImage: "flame.fill")
                }
                Text("昵称：\(viewModel.profile.account.nick)")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 28)
        .padding(.horizontal, AppTheme.verticalSpacing)
        .smthSurfaceBackground()
    }

    private func badge(text: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.system(.caption, design: .rounded).weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(AppTheme.accentColor(for: colorScheme).opacity(0.16))
        )
        .foregroundStyle(AppTheme.accentColor(for: colorScheme))
    }

    private func actionSection(title: String, rows: [ProfileRow]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    Group {
                        if let destination = row.destination {
                            NavigationLink(value: destination) {
                                actionRow(row)
                            }
                            .buttonStyle(.plain)
                        } else {
                            actionRow(row)
                                .opacity(0.6)
                        }
                    }

                    if index < rows.count - 1 {
                        Divider()
                            .overlay(AppTheme.borderColor(for: colorScheme))
                            .padding(.leading, 52)
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, AppTheme.verticalSpacing)
            .smthSurfaceBackground(subdued: true)
        }
    }

    private func actionRow(_ row: ProfileRow) -> some View {
        HStack(spacing: 16) {
            Image(systemName: row.icon)
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(AppTheme.accentColor(for: colorScheme).opacity(0.14))
                )
                .foregroundStyle(AppTheme.accentColor(for: colorScheme))

            VStack(alignment: .leading, spacing: 4) {
                Text(row.title)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundColor(.primary)
                Text(row.subtitle)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if row.destination != nil {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            } else {
                Text("敬请期待")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AppTheme.subduedSurface(for: colorScheme))
                    )
            }
        }
        .padding(.vertical, 18)
    }

    private var guestCard: some View {
        VStack(spacing: 18) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(AppTheme.accentColor(for: colorScheme))
            Text("登录后可查看完整资料和功能")
                .font(.system(.headline, design: .rounded))
            Text("同步收藏、历史记录与个性化设置。")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
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
        .smthSurfaceBackground()
    }

    private func errorCard(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("重试") {
                Task {
                    await viewModel.loadProfile()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 48)
        .padding(.horizontal, 36)
        .smthSurfaceBackground(subdued: true)
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

private struct ProfileRow: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let destination: ProfileDestination?
}
