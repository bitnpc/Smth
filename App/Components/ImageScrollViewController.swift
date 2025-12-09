//
//  ImageScrollViewController.swift
//  Smth
//
//  单张图片的滚动视图控制器，支持缩放和拖拽
//  Created by tony
//

import UIKit
import SnapKit

final class ImageScrollViewController: UIViewController {
    private let imageUrl: String
    private let index: Int
    private let onDismiss: () -> Void
    
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    private var imageLoader: CachedImageLoader?
    private var activityIndicator: UIActivityIndicatorView?
    private var lastScrollViewSize: CGSize = .zero
    private var hasInitialLayout: Bool = false
    
    init(imageUrl: String, index: Int, onDismiss: @escaping () -> Void) {
        self.imageUrl = imageUrl
        self.index = index
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupConstraints()
        loadImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let currentSize = scrollView.bounds.size
        
        // 确保有有效尺寸
        guard currentSize.width > 0 && currentSize.height > 0 else { return }
        
        let sizeChanged = currentSize != lastScrollViewSize
        
        // 如果尺寸改变，或者图片已加载但还未初始化布局，则更新
        if sizeChanged && imageView.image != nil {
            lastScrollViewSize = currentSize
            // 只在尺寸改变时更新，保持当前的缩放状态
            updateImageViewSize(preserveZoom: hasInitialLayout)
            hasInitialLayout = true
        } else if !hasInitialLayout && imageView.image != nil {
            // 如果图片已加载但还未初始化布局，现在布局已经完成，立即更新
            lastScrollViewSize = currentSize
            updateImageViewSize(preserveZoom: false)
            hasInitialLayout = true
        }
    }
    
    private func setupScrollView() {
        view.backgroundColor = .black
        
        // 创建 ScrollView
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .black
        scrollView.bouncesZoom = true
        
        // 创建 ImageView
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .clear
        
        // 添加双击手势
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
        
        // 添加单击手势（关闭）
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        view.addGestureRecognizer(singleTap)
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
    }
    
    private func setupConstraints() {
        // ScrollView 全屏布局，不留 safe area 间隙
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadImage() {
        guard let url = URL(string: imageUrl) else { return }
        
        // 显示加载指示器
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        self.activityIndicator = activityIndicator
        view.addSubview(activityIndicator)
        
        // 使用 SnapKit 布局加载指示器
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        activityIndicator.startAnimating()
        
        // 使用 CachedImageLoader 加载图片
        imageLoader = CachedImageLoader()
        imageLoader?.loadImage(from: url) { [weak self] image in
            DispatchQueue.main.async {
                self?.activityIndicator?.stopAnimating()
                self?.activityIndicator?.removeFromSuperview()
                self?.activityIndicator = nil
                
                if let image = image {
                    self?.imageView.image = image
                    // 确保在主线程的下一轮 run loop 中更新，此时布局应该已经完成
                    DispatchQueue.main.async {
                        if let scrollViewSize = self?.scrollView.bounds.size,
                           scrollViewSize.width > 0 && scrollViewSize.height > 0 {
                            // 如果布局已完成，立即更新
                            self?.updateImageViewSize(preserveZoom: false)
                            self?.hasInitialLayout = true
                            self?.lastScrollViewSize = scrollViewSize
                        } else {
                            // 如果布局还未完成，标记为未初始化，等待 viewDidLayoutSubviews
                            self?.hasInitialLayout = false
                        }
                    }
                }
            }
        }
    }
    
    private func updateImageViewSize(preserveZoom: Bool = false) {
        guard let image = imageView.image else { return }
        
        let imageSize = image.size
        let scrollViewSize = scrollView.bounds.size
        
        guard scrollViewSize.width > 0 && scrollViewSize.height > 0,
              imageSize.width > 0 && imageSize.height > 0 else { return }
        
        let widthRatio = scrollViewSize.width / imageSize.width
        let heightRatio = scrollViewSize.height / imageSize.height
        let scale = min(widthRatio, heightRatio)
        
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        
        // 保存当前的缩放比例和偏移
        let currentZoomScale = scrollView.zoomScale
        let currentOffset = scrollView.contentOffset
        
        // 使用 frame 布局
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.frame = CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight)
        scrollView.contentSize = CGSize(width: scaledWidth, height: scaledHeight)
        
        if !preserveZoom {
            // 首次加载时重置缩放和偏移
            scrollView.zoomScale = scrollView.minimumZoomScale
            scrollView.contentOffset = .zero
        } else {
            // 保持缩放比例，但确保在有效范围内
            let adjustedZoomScale = max(scrollView.minimumZoomScale, min(scrollView.maximumZoomScale, currentZoomScale))
            scrollView.zoomScale = adjustedZoomScale
            // 调整偏移以确保在有效范围内
            let maxOffsetX = max(0, scrollView.contentSize.width - scrollView.bounds.width)
            let maxOffsetY = max(0, scrollView.contentSize.height - scrollView.bounds.height)
            scrollView.contentOffset = CGPoint(
                x: min(maxOffsetX, max(0, currentOffset.x)),
                y: min(maxOffsetY, max(0, currentOffset.y))
            )
        }
        
        // 居中显示（必须在设置 zoomScale 和 contentOffset 之后调用）
        centerImageView()
    }
    
    private func centerImageView() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        // 计算居中所需的 padding
        // 注意：需要考虑当前的 zoomScale
        let scaledWidth = imageViewSize.width * scrollView.zoomScale
        let scaledHeight = imageViewSize.height * scrollView.zoomScale
        
        let horizontalPadding = max(0, (scrollViewSize.width - scaledWidth) / 2)
        let verticalPadding = max(0, (scrollViewSize.height - scaledHeight) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        )
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            // 缩小
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            // 放大到指定点
            let point = gesture.location(in: imageView)
            let zoomScale: CGFloat = 2.0
            let zoomRect = CGRect(
                x: point.x - scrollView.bounds.width / (2 * zoomScale),
                y: point.y - scrollView.bounds.height / (2 * zoomScale),
                width: scrollView.bounds.width / zoomScale,
                height: scrollView.bounds.height / zoomScale
            )
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    @objc private func handleSingleTap() {
        onDismiss()
    }
}

// MARK: - UIScrollViewDelegate
extension ImageScrollViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 缩放时保持图片居中，使用 contentInset 而不是直接修改 frame
        centerImageView()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // 缩放结束后再次确保居中
        centerImageView()
    }
}

