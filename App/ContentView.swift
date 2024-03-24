//
//  ContentView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedTabIndex: Int = 0
    
    // all system image symble
    var body: some View {
        TabView (selection: $selectedTabIndex){
            HotTopicView().tabItem {
                Image(systemName: "star")
                Text("话题")
            }
            SectionView().tabItem {
                Image(systemName: "list.bullet.clipboard")
                Text("版面")
            }
            MineView().tabItem {
                Image(systemName: "person.circle")
                Text("我的")
            }
        }
    }
}

