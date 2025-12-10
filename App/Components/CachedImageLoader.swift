//
//  CachedImageLoader.swift
//  Smth
//
//  图片加载器，使用 ImageCache 进行缓存
//  Created by tony
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// 图片加载器，用于在 UIKit/AppKit 中加载和缓存图片
final class CachedImageLoader {
    private var task: URLSessionDataTask?
    
    #if os(iOS)
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // 取消之前的任务
        task?.cancel()
        
        // 尝试从缓存加载（异步）
        Task {
            if let cachedImage = await ImageCache.shared.image(for: url) {
                DispatchQueue.main.async {
                    completion(cachedImage)
                }
                return
            }
            
            // 从网络加载
            self.task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data,
                      error == nil else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                // 缓存图片（异步）
                Task {
                    await ImageCache.shared.setImage(image, for: url)
                }
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            self.task?.resume()
        }
    }
    #elseif os(macOS)
    func loadImage(from url: URL, completion: @escaping (NSImage?) -> Void) {
        // 取消之前的任务
        task?.cancel()
        
        // 尝试从缓存加载（异步）
        Task {
            if let cachedImage = await ImageCache.shared.image(for: url) {
                DispatchQueue.main.async {
                    completion(cachedImage)
                }
                return
            }
            
            // 从网络加载
            self.task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data,
                      error == nil else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                guard let image = NSImage(data: data) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                // 缓存图片（异步）
                Task {
                    await ImageCache.shared.setImage(image, for: url)
                }
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            self.task?.resume()
        }
    }
    #endif
    
    deinit {
        task?.cancel()
    }
}

