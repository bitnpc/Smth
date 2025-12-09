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
    
    var body: some View {
        // 简化版 SwiftUI 实现
        Text("ImageViewer for macOS - Not implemented")
            .foregroundColor(.white)
    }
}
#endif
