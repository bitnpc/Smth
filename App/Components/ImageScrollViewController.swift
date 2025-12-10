//
//  ImageScrollViewController.swift
//  Smth
//
//  单张图片的滚动视图控制器，支持缩放和拖拽
//  Created by tony
//

#if os(iOS)
import UIKit

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
        loadImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 设置 scrollView 的 frame
        scrollView.frame = view.bounds
        
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
        } else if imageView.image != nil && scrollView.contentSize.width > 0 {
            // 即使尺寸没有改变，也要确保居中（修复图片靠上的问题）
            centerImageView()
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
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    private func loadImage() {
        guard let url = URL(string: imageUrl) else { return }
        
        // 显示加载指示器
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator = activityIndicator
        view.addSubview(activityIndicator)
        
        // 使用 frame 布局加载指示器
        activityIndicator.sizeToFit()
        activityIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
        activityIndicator.startAnimating()
        
        // 使用 CachedImageLoader 加载图片
        imageLoader = CachedImageLoader()
        imageLoader?.loadImage(from: url) { [weak self] image in
            DispatchQueue.main.async {
                // 更新 activityIndicator 的位置（可能在 viewDidLayoutSubviews 中尺寸改变）
                if let activityIndicator = self?.activityIndicator {
                    activityIndicator.center = CGPoint(
                        x: self?.view.bounds.midX ?? 0,
                        y: self?.view.bounds.midY ?? 0
                    )
                }
                
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
        
        // 保存当前的缩放比例
        let currentZoomScale = scrollView.zoomScale
        
        // 设置 imageView 的 frame（这是基准尺寸）
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.frame = CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight)
        
        // contentSize 应该等于 imageView.frame.size
        // UIScrollView 在缩放时会自动管理显示，但 contentSize 保持不变
        scrollView.contentSize = CGSize(width: scaledWidth, height: scaledHeight)
        
        // 先重置 contentInset，避免影响 zoomScale 的设置
        scrollView.contentInset = .zero
        
        if !preserveZoom {
            // 首次加载时重置缩放和偏移
            scrollView.zoomScale = scrollView.minimumZoomScale
            scrollView.contentOffset = .zero
        } else {
            // 保持缩放比例，但确保在有效范围内
            let adjustedZoomScale = max(scrollView.minimumZoomScale, min(scrollView.maximumZoomScale, currentZoomScale))
            scrollView.zoomScale = adjustedZoomScale
        }
        
        // 居中显示（必须在设置 zoomScale 之后调用）
        // 使用 DispatchQueue 确保布局更新完成后再居中
        DispatchQueue.main.async { [weak self] in
            self?.centerImageView()
        }
    }
    
    private func centerImageView() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        guard scrollViewSize.width > 0 && scrollViewSize.height > 0,
              imageViewSize.width > 0 && imageViewSize.height > 0 else { return }
        
        // 计算居中所需的 padding
        // imageView.frame.size 是缩放前的尺寸（基准尺寸）
        // 实际的显示尺寸 = imageView.frame.size * zoomScale = contentSize
        // 但 contentSize 可能因为缩放而改变，所以我们使用 imageView.frame.size * zoomScale 来计算
        let currentZoomScale = scrollView.zoomScale
        let scaledWidth = imageViewSize.width * currentZoomScale
        let scaledHeight = imageViewSize.height * currentZoomScale
        
        let horizontalPadding = max(0, (scrollViewSize.width - scaledWidth) / 2)
        let verticalPadding = max(0, (scrollViewSize.height - scaledHeight) / 2)
        
        // 只有当图片尺寸小于 scrollView 时才需要 padding 来居中
        // 如果图片已经大于 scrollView，则不添加 padding（此时应该可以滚动查看）
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
#endif
