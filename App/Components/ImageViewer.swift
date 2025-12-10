//
//  ImageViewer.swift
//  Smth
//
//  图片查看器组件，提供图片的放大查看和滑动浏览功能
//  基于 UIKit 实现，提供流畅的手势体验
//  Created by tony
//

import SwiftUI

struct ImageViewer: View {
    let images: [String]
    let initialIndex: Int
    @Binding var isPresented: Bool
    @Binding var sourceFrame: CGRect?
    
    var body: some View {
        #if os(iOS)
        ImageViewerUIKit(
            images: images,
            initialIndex: initialIndex,
            isPresented: $isPresented,
            sourceFrame: sourceFrame
        )
        .ignoresSafeArea(.all)
        #else
        // macOS 或其他平台使用 SwiftUI 实现
        ImageViewerSwiftUI(
            images: images,
            initialIndex: initialIndex,
            isPresented: $isPresented,
            sourceFrame: sourceFrame
        )
        #endif
    }
}

#if os(iOS)
// MARK: - UIKit 实现（iOS）
private struct ImageViewerUIKit: UIViewControllerRepresentable {
    let images: [String]
    let initialIndex: Int
    @Binding var isPresented: Bool
    let sourceFrame: CGRect?
    
    func makeUIViewController(context: Context) -> ImagePageViewController {
        let controller = ImagePageViewController(
            images: images,
            initialIndex: initialIndex,
            onDismiss: {
                isPresented = false
            }
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ImagePageViewController, context: Context) {
        // 如果需要更新，可以在这里处理
    }
}
#endif

// MARK: - SwiftUI 实现（macOS 或其他平台）
#if !os(iOS)
private struct ImageViewerSwiftUI: View {
    let images: [String]
    let initialIndex: Int
    @Binding var isPresented: Bool
    let sourceFrame: CGRect?
    
    @State private var currentIndex: Int
    @State private var scale: CGFloat = 1.0
    
    init(images: [String], initialIndex: Int, isPresented: Binding<Bool>, sourceFrame: CGRect?) {
        self.images = images
        self.initialIndex = initialIndex
        self._isPresented = isPresented
        self.sourceFrame = sourceFrame
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if !images.isEmpty && currentIndex < images.count {
                ZStack {
                    // 图片视图
                    ScrollView([.horizontal, .vertical]) {
                        CachedAsyncImage(url: URL(string: images[currentIndex])) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(scale)
                        } placeholder: {
                            ProgressView()
                                .tint(.white)
                        }
                        .frame(
                            minWidth: 400 * scale,
                            minHeight: 300 * scale
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                            .onEnded { _ in
                                if scale < 1.0 {
                                    withAnimation {
                                        scale = 1.0
                                    }
                                } else if scale > 4.0 {
                                    scale = 4.0
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            if scale > 1.0 {
                                scale = 1.0
                            } else {
                                scale = 2.0
                            }
                        }
                    }
                    
                    // 上一张按钮
                    if images.count > 1 && currentIndex > 0 {
                        HStack {
                            Button {
                                withAnimation {
                                    currentIndex -= 1
                                    scale = 1.0
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                    )
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                            Spacer()
                        }
                        .padding(.leading, 20)
                    }
                    
                    // 下一张按钮
                    if images.count > 1 && currentIndex < images.count - 1 {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    currentIndex += 1
                                    scale = 1.0
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                    )
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        }
                        .padding(.trailing, 20)
                    }
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .padding()
                    }
                    Spacer()
                    if images.count > 1 {
                        HStack {
                            Spacer()
                            Text("\(currentIndex + 1) / \(images.count)")
                                .foregroundColor(.white.opacity(0.8))
                                .padding()
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            currentIndex = initialIndex
        }
    }
}
#endif
