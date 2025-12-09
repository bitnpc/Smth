//
//  ImageGroupView.swift
//  Smth
//
//  图片组视图组件，展示多张图片的网格布局
//  Created by tony
//

import SwiftUI

private struct ImageIndex: Identifiable {
    let id: Int
}

struct ImageGroupView: View {
    let attachments: [Attachment]
    
    @State private var selectedImageIndex: ImageIndex?
    @State private var sourceFrame: CGRect?
    
    var body: some View {
        let images = attachments.filter { attachment in
            !attachment.id.isEmpty
        }
        let imageUrls = images.map { $0.ks3Url ?? $0.cdnUrl }
        
        return VStack(alignment: .leading) {
            ForEach(0..<(images.count + 2) / 3, id: \.self) { groupIndex in
                HStack {
                    ForEach(0..<3, id: \.self) { itemIndex in
                        let index = groupIndex * 3 + itemIndex
                        if index < images.count {
                            imageItem(
                                url: imageUrls[index],
                                index: index,
                                totalImages: imageUrls
                            )
                        }
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedImageIndex) { imageIndex in
            ImageViewer(
                images: imageUrls,
                initialIndex: imageIndex.id,
                isPresented: Binding(
                    get: { selectedImageIndex != nil },
                    set: { if !$0 { selectedImageIndex = nil } }
                ),
                sourceFrame: $sourceFrame
            )
        }
    }
    
    @ViewBuilder
    private func imageItem(url: String, index: Int, totalImages: [String]) -> some View {
        GeometryReader { geometry in
            CachedAsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "photo.fill")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 100, height: 80)
            .clipped()
            .contentShape(Rectangle())
            .onTapGesture {
                // 获取图片在屏幕中的位置
                let frame = geometry.frame(in: .global)
                sourceFrame = frame
                // 设置 selectedImageIndex，这会触发 fullScreenCover
                selectedImageIndex = ImageIndex(id: index)
            }
        }
        .frame(width: 100, height: 80)
    }
}
