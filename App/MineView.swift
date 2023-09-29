//
//  MineView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct MineView: View {
    
    @State private var showLoginView = false

    var body: some View {
        Button("Login") {
            showLoginView = true
        }.sheet(isPresented: $showLoginView) {
            LoginView()
        }
    }
}
