//
//  LoginView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI
import WebKit

struct LoginView: View {
    
    @Binding var showLoginView: Bool
    
    var body: some View {
        VStack (alignment: .trailing) {
            Button("close") {
                
            }.padding(10)
            WebView(url: URL(string: "https://wap.newsmth.net/login")!, onComplete: {
                showLoginView = false
            })
//            WebView(url: ) {
//                print("finish")
//            })
        }
    }
}
