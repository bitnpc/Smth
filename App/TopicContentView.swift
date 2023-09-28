//
//  TopicContentView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import SwiftUI

struct TopicContentView: View {
    
    let article: Article?
    
    var body: some View {
        if article == nil {
            Text("Loading")
        }else {
            VStack (alignment: .leading) {
                Text(article!.subject).font(.title2)
                HStack {
                    Text(article!.account.name)
                    Spacer()
                    Text(String(article!.postTimeString))
                }
                .frame(height: 30)
                Text(article!.content).font(.body)
            }
        }
    }
}


