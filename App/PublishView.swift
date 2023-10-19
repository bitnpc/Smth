//
//  PublishView.swift
//  Smth
//
//  Created by Tony Clark on 2023/10/1.
//

import SwiftUI

struct PublishView: View {
    
    @State private var title = ""
    @State private var content = "输入内容"

    var body: some View {
//        NavigationStack {
            VStack (alignment: .leading) {
                TextField(text: $title) {
                    Text("输入标题").foregroundStyle(.gray)
                }.padding()
                TextEditor(text: $content)
                    .font(.title)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .padding()
                    .frame(maxHeight: 200)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1).padding()
                    }
                Spacer()
            }
//            .navigationTitle("新主题")
            .toolbar {
                ToolbarItem(placement: .primaryAction, content: {
                    Image("paperplane.fill")
                })
            }
//        }
        
        
    }
}

#Preview {
    PublishView()
}
