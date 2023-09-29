//
//  ContentView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedTabIndex = 0;
    
    // all system image symble
    var body: some View {
            TabView (selection: $selectedTabIndex){
                HotTopicView().tabItem {
                    Image(systemName: "star")
                }
                SectionListView().tabItem {
                    Image(systemName: "list.bullet.clipboard")
                }
                MineView().tabItem {
                    Image(systemName: "person.circle")
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
