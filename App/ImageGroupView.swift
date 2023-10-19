//
//  ImageGroupView.swift
//  Smth
//
//  Created by Tony Clark on 2023/10/15.
//

import SwiftUI

struct ImageGroupView: View {
    
    let attachments: [Attachment]
    
    var body: some View {
//        GeometryReader { geometry in
            VStack (alignment: .leading) {
                let images = attachments.filter { attachment in
                    return !attachment.id.isEmpty
                }
                ForEach(0..<(images.count + 2) / 3, id: \.self) { groupIndex in
                    HStack {
                        ForEach(0..<3, id: \.self) { itemIndex in
                            let index = groupIndex * 3 + itemIndex
                            if index < images.count {
                                AsyncImage(url: URL.init(string: images[index].ks3Url)) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 80).clipped()
                                } placeholder: {
                                    Image(systemName: "photo.fill").resizable().frame(width: 100, height: 80).clipped()
                                }
                            }
                        }
                    }
                }
            }
//        }
    }
}
