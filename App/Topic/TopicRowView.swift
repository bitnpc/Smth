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
            Text(topic.subject).font(.body).lineLimit(1)
            Spacer().frame(height: 8)
            HStack {
                Text(String(topic.availables) + "回复").font(.footnote).foregroundColor(.gray)
                Text(String(topic.likeAvailables) + "Like").font(.footnote).foregroundColor(.gray)
                Spacer()
                Text(String(topic.board!.title)).font(.footnote).foregroundColor(.gray)
            }.padding(.top, 5)
        }
    }
}
