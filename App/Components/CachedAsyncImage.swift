//
//  CachedAsyncImage.swift
//  Smth
//
//  缓存异步图片组件，提供带缓存的图片加载功能
//  Created by tony
//

import SwiftUI

/// 带缓存的异步图片加载组件
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var hasError = false
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else {
            isLoading = false
            hasError = true
            return
        }
        
        // 先尝试从缓存加载
        if let cachedImage = await ImageCache.shared.image(for: url) {
            image = cachedImage
            isLoading = false
            hasError = false
            return
        }
        
        // 从网络加载
        isLoading = true
        hasError = false
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let loadedImage = UIImage(data: data) {
                // 保存到缓存
                await ImageCache.shared.setImage(loadedImage, for: url)
                image = loadedImage
                hasError = false
            } else {
                hasError = true
            }
        } catch {
            // 加载失败
            hasError = true
        }
        isLoading = false
    }
}

// MARK: - Phase-based Version (兼容 AsyncImage 的 phase 用法)

/// 支持 phase 参数的带缓存异步图片组件
struct CachedAsyncImagePhase<Content: View>: View {
    let url: URL?
    @ViewBuilder let content: (AsyncImagePhase) -> Content
    
    @State private var phase: AsyncImagePhase = .empty
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.content = content
    }
    
    var body: some View {
        content(phase)
            .task {
                await loadImage()
            }
    }
    
    private func loadImage() async {
        guard let url = url else {
            phase = .failure(URLError(.badURL))
            return
        }
        
        // 先尝试从缓存加载
        if let cachedImage = await ImageCache.shared.image(for: url) {
            phase = .success(Image(uiImage: cachedImage))
            return
        }
        
        // 从网络加载
        phase = .empty
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let loadedImage = UIImage(data: data) {
                // 保存到缓存
                await ImageCache.shared.setImage(loadedImage, for: url)
                phase = .success(Image(uiImage: loadedImage))
            } else {
                phase = .failure(URLError(.cannotDecodeContentData))
            }
        } catch {
            phase = .failure(error)
        }
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Content == Image, Placeholder == Image {
    init(url: URL?) {
        self.init(
            url: url,
            content: { $0 },
            placeholder: { Image(systemName: "photo") }
        )
    }
}

extension CachedAsyncImage where Placeholder == Image {
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: url,
            content: content,
            placeholder: { Image(systemName: "photo") }
        )
    }
}

