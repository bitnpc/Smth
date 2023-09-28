//
//  ContentView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var dataSource = TopicDataSource()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataSource.topics, id: \.id) { topic in
                    NavigationLink(value: topic) {
                        Text("\(topic.subject)")
                    }
                }
            }
            .onAppear() {
                Task {
                    await dataSource.fetchTopics()
                }
            }
            .navigationTitle("热门")
            .navigationDestination(for: Topic.self) { topic in
                TopicDetailView(topic: topic)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
