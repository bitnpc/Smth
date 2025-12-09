//
//  ImageCache.swift
//  Smth
//
//  图片缓存管理，提供图片的下载、缓存和内存管理功能
//  Created by tony
//

import Foundation
import UIKit

/// 图片缓存管理器，使用 NSCache 和磁盘缓存
/// NSCache 是线程安全的，可以在任何线程使用
final class ImageCache {
    static let shared = ImageCache()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheURL: URL
    private let fileManager = FileManager.default
    private let maxMemoryCacheSize = 50 * 1024 * 1024 // 50MB
    private let maxDiskCacheSize = 200 * 1024 * 1024 // 200MB
    private let queue = DispatchQueue(label: "com.smth.imagecache", attributes: .concurrent)
    
    private init() {
        // 配置内存缓存
        memoryCache.totalCostLimit = maxMemoryCacheSize
        memoryCache.countLimit = 100
        
        // 配置磁盘缓存目录
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDirectory.appendingPathComponent("ImageCache", isDirectory: true)
        
        // 创建缓存目录
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        
        // 启动时清理过期缓存
        Task.detached {
            await self.cleanExpiredCache()
        }
    }
    
    /// 从缓存中获取图片
    func image(for url: URL) async -> UIImage? {
        let key = cacheKey(for: url)
        
        // 先检查内存缓存
        if let cachedImage = memoryCache.object(forKey: key as NSString) {
            return cachedImage
        }
        
        // 检查磁盘缓存
        if let diskImage = await loadFromDisk(key: key) {
            // 将磁盘缓存加载到内存缓存
            memoryCache.setObject(diskImage, forKey: key as NSString, cost: imageCost(diskImage))
            return diskImage
        }
        
        return nil
    }
    
    /// 将图片保存到缓存
    func setImage(_ image: UIImage, for url: URL) async {
        let key = cacheKey(for: url)
        
        // 保存到内存缓存
        memoryCache.setObject(image, forKey: key as NSString, cost: imageCost(image))
        
        // 保存到磁盘缓存
        await saveToDisk(image: image, key: key)
    }
    
    /// 清除所有缓存
    func clearCache() async {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheURL)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    
    /// 清理过期缓存
    private func cleanExpiredCache() async {
        guard let files = try? fileManager.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: [.contentModificationDateKey]) else {
            return
        }
        
        let now = Date()
        let expirationInterval: TimeInterval = 7 * 24 * 60 * 60 // 7天
        
        var totalSize: Int64 = 0
        var filesToDelete: [URL] = []
        
        for file in files {
            if let attributes = try? file.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]),
               let modificationDate = attributes.contentModificationDate,
               let fileSize = attributes.fileSize {
                totalSize += Int64(fileSize)
                
                // 如果文件过期，标记为删除
                if now.timeIntervalSince(modificationDate) > expirationInterval {
                    filesToDelete.append(file)
                }
            }
        }
        
        // 删除过期文件
        for file in filesToDelete {
            try? fileManager.removeItem(at: file)
        }
        
        // 如果总大小超过限制，删除最旧的文件
        if totalSize > maxDiskCacheSize {
            let sortedFiles = files.sorted { file1, file2 in
                guard let date1 = try? file1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
                      let date2 = try? file2.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate else {
                    return false
                }
                return date1 < date2
            }
            
            var currentSize = totalSize
            for file in sortedFiles {
                if currentSize <= maxDiskCacheSize {
                    break
                }
                if let fileSize = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    try? fileManager.removeItem(at: file)
                    currentSize -= Int64(fileSize)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func cacheKey(for url: URL) -> String {
        return url.absoluteString
    }
    
    private func imageCost(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.width * cgImage.height * 4 // 假设 RGBA，每像素4字节
    }
    
    private func diskCachePath(for key: String) -> URL {
        // 使用 URL 的哈希值作为文件名，避免特殊字符问题
        let fileName = String(key.hash)
        return diskCacheURL.appendingPathComponent(fileName)
    }
    
    private func loadFromDisk(key: String) async -> UIImage? {
        return await Task.detached {
            let filePath = self.diskCachePath(for: key)
            guard let data = try? Data(contentsOf: filePath),
                  let image = UIImage(data: data) else {
                return nil
            }
            return image
        }.value
    }
    
    private func saveToDisk(image: UIImage, key: String) async {
        await Task.detached {
            guard let data = image.jpegData(compressionQuality: 0.8) else { return }
            let filePath = self.diskCachePath(for: key)
            try? data.write(to: filePath)
        }.value
    }
}

