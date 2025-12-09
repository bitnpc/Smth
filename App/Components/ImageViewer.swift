//
//  ImageViewer.swift
//  Smth
//
//  图片查看器组件，提供图片的放大查看和滑动浏览功能
//  Created by tony
//

import SwiftUI

struct ImageViewer: View {
    let images: [String]
    let initialIndex: Int
    @Binding var isPresented: Bool
    @Binding var sourceFrame: CGRect?
    
    @State private var currentIndex: Int
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var dragOffset: CGFloat = 0
    @State private var isClosing = false
    @State private var animationProgress: CGFloat = 0
    
    init(images: [String], initialIndex: Int, isPresented: Binding<Bool>, sourceFrame: Binding<CGRect?>) {
        self.images = images
        self.initialIndex = initialIndex
        self._isPresented = isPresented
        self._sourceFrame = sourceFrame
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack {
            // 黑色背景
            Color.black
                .ignoresSafeArea()
                .opacity(animationProgress)
            
            // 图片容器
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                let sourceFrameValue = sourceFrame ?? CGRect.zero
                
                HStack(spacing: 0) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, imageUrl in
                        imageView(
                            for: imageUrl,
                            index: index,
                            geometry: geometry,
                            sourceFrame: index == initialIndex ? sourceFrameValue : nil,
                            screenSize: CGSize(width: screenWidth, height: screenHeight)
                        )
                        .frame(width: geometry.size.width)
                    }
                }
                .offset(x: -CGFloat(currentIndex) * geometry.size.width + dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // 如果当前图片未放大，允许左右滑动切换
                            if scale <= 1.0 && !isClosing {
                                dragOffset = value.translation.width
                            }
                        }
                        .onEnded { value in
                            if scale <= 1.0 && !isClosing {
                                let threshold: CGFloat = 50
                                if value.translation.width > threshold && currentIndex > 0 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        currentIndex -= 1
                                    }
                                } else if value.translation.width < -threshold && currentIndex < images.count - 1 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        currentIndex += 1
                                    }
                                }
                            }
                            dragOffset = 0
                        }
                )
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button {
                        closeViewer()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                Spacer()
            }
            .opacity(isClosing ? 0 : animationProgress)
            
            // 页码指示器
            if images.count > 1 {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(0..<images.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? Color.white : Color.white.opacity(0.4))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .opacity(isClosing ? 0 : animationProgress)
            }
        }
        .onAppear {
            currentIndex = initialIndex
            // 开始进入动画
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func closeViewer() {
        guard !isClosing else { return }
        isClosing = true
        
        // 先重置缩放和偏移
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scale = 1.0
            offset = .zero
            lastScale = 1.0
            lastOffset = .zero
        }
        
        // 然后关闭，动画会从全屏回到源位置
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                animationProgress = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isPresented = false
            }
        }
    }
    
    private func imageView(
        for imageUrl: String,
        index: Int,
        geometry: GeometryProxy,
        sourceFrame: CGRect?,
        screenSize: CGSize
    ) -> some View {
        let isCurrentImage = index == currentIndex
        let isInitialImage = index == initialIndex
        // 打开动画：只有初始图片需要从源位置动画到全屏
        // 关闭动画：只有当前图片是初始图片时才回到源位置，否则淡出
        let shouldAnimateOpen = !isClosing && isInitialImage
        let shouldAnimateClose = isClosing && isCurrentImage && isInitialImage
        let hasSourceFrame = sourceFrame != nil && !(sourceFrame?.isEmpty ?? true) && (shouldAnimateOpen || shouldAnimateClose)
        
        // 计算从源位置到屏幕中心的变换
        let sourceFrameValue = hasSourceFrame ? (sourceFrame ?? CGRect.zero) : CGRect(
            x: screenSize.width / 2 - 50,
            y: screenSize.height / 2 - 40,
            width: 100,
            height: 80
        )
        
        let sourceCenterX = sourceFrameValue.midX
        let sourceCenterY = sourceFrameValue.midY
        let sourceWidth = sourceFrameValue.width
        let sourceHeight = sourceFrameValue.height
        
        let targetCenterX = screenSize.width / 2
        let targetCenterY = screenSize.height / 2
        
        // 计算缩放比例 - 使用 fit 模式，保持宽高比
        let imageAspectRatio: CGFloat = sourceWidth > 0 && sourceHeight > 0 ? sourceWidth / sourceHeight : 1.0
        let screenAspectRatio = screenSize.width / screenSize.height
        
        let targetScale: CGFloat
        if imageAspectRatio > screenAspectRatio {
            // 图片更宽，以宽度为准
            targetScale = screenSize.width / max(sourceWidth, 1)
        } else {
            // 图片更高，以高度为准
            targetScale = screenSize.height / max(sourceHeight, 1)
        }
        
        // 计算偏移
        let offsetX = targetCenterX - sourceCenterX
        let offsetY = targetCenterY - sourceCenterY
        
        // 应用动画进度
        let currentScale: CGFloat
        let currentOffsetX: CGFloat
        let currentOffsetY: CGFloat
        let imageOpacity: CGFloat
        
        if isClosing && isCurrentImage && isInitialImage && hasSourceFrame {
            // 关闭动画：从全屏回到源位置（只有初始图片）
            currentScale = 1.0 + (targetScale - 1.0) * (1.0 - animationProgress)
            currentOffsetX = offsetX * (1.0 - animationProgress)
            currentOffsetY = offsetY * (1.0 - animationProgress)
            imageOpacity = animationProgress
        } else if isClosing && isCurrentImage && !isInitialImage {
            // 关闭动画：非初始图片淡出
            currentScale = targetScale
            currentOffsetX = 0
            currentOffsetY = 0
            imageOpacity = animationProgress
        } else if !isClosing && isInitialImage && hasSourceFrame {
            // 打开动画：从源位置到全屏
            currentScale = 1.0 + (targetScale - 1.0) * animationProgress
            currentOffsetX = offsetX * animationProgress
            currentOffsetY = offsetY * animationProgress
            imageOpacity = 1.0
        } else {
            // 非初始图片或没有源位置
            if isClosing {
                // 关闭时，所有图片都淡出
                currentScale = isCurrentImage ? targetScale : 1.0
                currentOffsetX = 0
                currentOffsetY = 0
                imageOpacity = animationProgress
            } else {
                // 正常显示
                currentScale = isCurrentImage ? targetScale : 1.0
                currentOffsetX = 0
                currentOffsetY = 0
                imageOpacity = isCurrentImage ? 1.0 : 0.0
            }
        }
        
        return ZStack {
            Color.clear
            
            CachedAsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ZStack {
                    Color.black.opacity(0.3)
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(width: screenSize.width, height: screenSize.height)
            .opacity(imageOpacity)
            .scaleEffect(isCurrentImage ? (currentScale * scale) : 1.0)
            .offset(
                x: isCurrentImage ? (currentOffsetX + offset.width) : 0,
                y: isCurrentImage ? (currentOffsetY + offset.height) : 0
            )
            .gesture(
                SimultaneousGesture(
                    // 双击放大/缩小
                    TapGesture(count: 2)
                        .onEnded {
                            guard !isClosing else { return }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if scale > 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                    lastScale = 1.0
                                    lastOffset = .zero
                                } else {
                                    scale = 2.0
                                    lastScale = 2.0
                                }
                            }
                        },
                    // 双指缩放
                    MagnificationGesture()
                        .onChanged { value in
                            guard !isClosing else { return }
                            let delta = value / lastScale
                            lastScale = value
                            scale = min(max(scale * delta, 1.0), 4.0)
                        }
                        .onEnded { _ in
                            guard !isClosing else { return }
                            lastScale = scale
                            if scale < 1.0 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                    lastScale = 1.0
                                }
                            }
                        }
                )
            )
            .gesture(
                // 拖拽（仅在放大时）
                DragGesture()
                    .onChanged { value in
                        guard !isClosing && scale > 1.0 else { return }
                        offset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        if scale > 1.0 {
                            lastOffset = offset
                        }
                    }
            )
            .gesture(
                // 向下拖拽关闭（仅在未放大时）
                DragGesture()
                    .onChanged { value in
                        guard !isClosing && scale <= 1.0 && value.translation.height > 0 else { return }
                        // 可以添加一些视觉反馈
                    }
                    .onEnded { value in
                        guard !isClosing && scale <= 1.0 && value.translation.height > 100 else { return }
                        closeViewer()
                    }
            )
        }
        .onChange(of: currentIndex) { _, _ in
            // 切换图片时重置缩放和偏移
            guard !isClosing else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                scale = 1.0
                offset = .zero
                lastScale = 1.0
                lastOffset = .zero
            }
        }
    }
}
