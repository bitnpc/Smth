//
//  ArticleRowView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI

struct ArticleRowView: View {
    
    let article: Article
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                AsyncImage(url: URL.init(string: article.account.avatarUrl)) { image in
                    image.resizable()
                        .frame(maxWidth: 30, maxHeight: 30)
                        .cornerRadius(15)
                } placeholder: {
                    Image(systemName: "photo")
                }
                Text(article.account.name)
                Spacer()            }
            .frame(height: 50)
            Text(article.content).font(.body).lineSpacing(6)
            if (article.quoteContent.count != 0) {
                Text(article.quoteContent)
                    .font(.footnote)
                    .lineSpacing(8)
                    .lineLimit(5)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
        }
    }
}
