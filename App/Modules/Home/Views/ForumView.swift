//
//  ForumView.swift
//  Smth
//
//  Created as part of the 2025 refactor.
//

import SwiftUI

struct ForumView: View {
    @State private var viewModel: ForumViewModel

    init(viewModel: ForumViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ListLayout(topics: viewModel.topics)
                    .overlay(alignment: .center) {
                        if viewModel.state == .loading {
                            ProgressView()
                        }
                    }
                    .animation(.easeInOut, value: viewModel.topics)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                Task {
                                    await viewModel.load()
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                            .disabled(viewModel.state == .loading)
                            .accessibilityLabel("刷新话题列表")
                        }
                    }
                    .task {
                        await viewModel.load()
                    }
                    .refreshable {
                        await viewModel.load()
                    }
                    .onChange(of: viewModel.topics) { _ in
                        guard let first = viewModel.topics.first else { return }
                        withAnimation(.spring()) {
                            proxy.scrollTo(first.id, anchor: .top)
                        }
                    }
                    .alert(
                        "加载失败",
                        isPresented: .constant(failureMessage != nil),
                        actions: {
                            Button("确定", role: .cancel) {}
                            Button("重试") {
                                Task { await viewModel.load() }
                            }
                        },
                        message: {
                            if let failureMessage {
                                Text(failureMessage)
                            }
                        }
                    )
            }
            .navigationTitle("今日热点")
        }
    }

    private var failureMessage: String? {
        guard case let .failed(error) = viewModel.state else { return nil }
        return error.errorDescription
    }
}

private struct ListLayout: View {
    let topics: [Topic]

    var body: some View {
        ScrollView {
            ResponsiveLayout(topics: topics)
                .padding(.horizontal, 16)
                .padding(.top, 16)
        }
        .scrollIndicators(.visible)
    }
}

private struct ResponsiveLayout: View {
    let topics: [Topic]

    var body: some View {
        AdaptivePlatformView {
            #if os(iOS)
            responsiveLayout(for: topics)
            #elseif os(macOS)
            responsiveLayout(for: topics)
            #elseif os(tvOS)
            responsiveLayout(for: topics)
            #else
            responsiveLayout(for: topics)
            #endif
        }
    }

    @ViewBuilder
    private func responsiveLayout(for posts: [Topic]) -> some View {
#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16)]) {
                ForEach(posts) { topic in
                    TopicCardContainer {
                        TopicRowView(topic: topic)
                    }
                    .id(topic.id)
                }
            }
        } else {
            LazyVStack(spacing: 12) {
                ForEach(posts) { topic in
                    TopicRowView(topic: topic)
                        .id(topic.id)
                }
            }
        }
#else
        LazyVStack(spacing: 12) {
            ForEach(posts) { topic in
                TopicRowView(topic: topic)
                    .id(topic.id)
            }
        }
#endif
    }
}

private struct TopicCardContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            .accessibilityElement(children: .combine)
    }
}

private struct AdaptivePlatformView<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        #if os(iOS)
        content()
        #elseif os(macOS)
        content()
            .padding(.horizontal, 24)
        #else
        content()
        #endif
    }
}

