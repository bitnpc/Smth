//
//  TopicRowView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI

struct TopicRowView: View {
    
    let topic: Topic
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(topic.subject).font(.headline).lineLimit(2)
            Spacer().frame(height: 8)
            Text(topic.article!.body).lineLimit(2)
            
            HStack {
                AsyncImage(url: URL.init(string: topic.article!.account.avatarUrl)) { image in
                    image.resizable()
                        .frame(maxWidth: 30, maxHeight: 30)
                        .cornerRadius(15)
                } placeholder: {
                    Image(systemName: "photo")
                }
                Text(topic.article!.account.name).font(.footnote)
                Text(String(topic.availables) + "回复").font(.footnote)
                Text(String(topic.likeAvailables) + "Like").font(.footnote)
                Spacer()
                Text(String(topic.board!.title)).font(.footnote)
            }
        }
        
    }
}
