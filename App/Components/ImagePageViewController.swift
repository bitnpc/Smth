//
//  ImagePageViewController.swift
//  Smth
//
//  图片分页视图控制器，使用 UIPageViewController 实现左右滑动
//  Created by tony
//

import UIKit
import SnapKit

final class ImagePageViewController: UIPageViewController {
    private let images: [String]
    private let initialIndex: Int
    private let onDismiss: () -> Void
    private var imageViewControllers: [ImageScrollViewController] = []
    private var currentIndex: Int = 0
    private var closeButton: UIButton?
    private var pageControl: UIPageControl?
    
    init(images: [String], initialIndex: Int, onDismiss: @escaping () -> Void) {
        self.images = images
        self.initialIndex = initialIndex
        self.onDismiss = onDismiss
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        dataSource = self
        delegate = self
        
        // 创建所有图片视图控制器
        imageViewControllers = images.enumerated().map { index, imageUrl in
            ImageScrollViewController(imageUrl: imageUrl, index: index, onDismiss: onDismiss)
        }
        
        currentIndex = initialIndex
        if let initialVC = imageViewControllers[safe: initialIndex] {
            setViewControllers([initialVC], direction: .forward, animated: false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // 确保 UIPageViewController 的背景视图也是黑色
        for subview in view.subviews {
            if subview is UIScrollView {
                subview.backgroundColor = .black
            }
        }
        
        setupCloseButton()
        setupPageIndicator()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 再次确保背景为黑色
        view.backgroundColor = .black
        for subview in view.subviews {
            if subview is UIScrollView {
                subview.backgroundColor = .black
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white.withAlphaComponent(0.8)
        closeButton.backgroundColor = .clear
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        self.closeButton = closeButton
        view.addSubview(closeButton)
    }
    
    private func setupConstraints() {
        guard let closeButton = closeButton else { return }
        
        // 关闭按钮布局
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
        }
        
        // 页码指示器布局
        if let pageControl = pageControl {
            pageControl.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            }
        }
    }
    
    @objc private func closeTapped() {
        onDismiss()
    }
    
    private func setupPageIndicator() {
        guard images.count > 1 else { return }
        
        let pageControl = UIPageControl()
        pageControl.numberOfPages = images.count
        pageControl.currentPage = currentIndex
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .white.withAlphaComponent(0.4)
        self.pageControl = pageControl
        
        view.addSubview(pageControl)
    }
    
    private func updatePageIndicator() {
        pageControl?.currentPage = currentIndex
    }
}

// MARK: - UIPageViewControllerDataSource
extension ImagePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? ImageScrollViewController,
              let index = imageViewControllers.firstIndex(of: vc),
              index > 0 else {
            return nil
        }
        return imageViewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? ImageScrollViewController,
              let index = imageViewControllers.firstIndex(of: vc),
              index < imageViewControllers.count - 1 else {
            return nil
        }
        return imageViewControllers[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension ImagePageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let currentVC = pageViewController.viewControllers?.first as? ImageScrollViewController,
           let index = imageViewControllers.firstIndex(of: currentVC) {
            currentIndex = index
            updatePageIndicator()
        }
    }
}

// MARK: - Array Safe Access Extension
private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

