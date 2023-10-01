//
//  TopicContentRowView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI

struct TopicContentRowView: View {
    
    let article: Article
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(article.subject).font(.title2)
            HStack {
                AsyncImage(url: URL.init(string: article.account.avatarUrl)) { image in
                    image.resizable()
                        .frame(maxWidth: 30, maxHeight: 30)
                        .cornerRadius(15)
                } placeholder: {
                    Image(systemName: "person.circle").frame(maxWidth: 30, maxHeight: 30)
                }
                Text(article.account.name)
                Spacer()
                Text(String(article.postTimeString)).font(.caption).foregroundColor(.gray)
            }
            .frame(height: 50)
            Text(article.content).font(.body).lineSpacing(6)
        }
    }
}


