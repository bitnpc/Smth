//
//  SectionListView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/29.
//

import SwiftUI

struct SectionListView: View {
    
    @StateObject var dataSource = SectionDataSource()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataSource.sections, id: \.id) { section in
                    NavigationLink(value: section) {
                        Text(section.name)
                    }
                }
            }
            .onAppear() {
                Task {
                    await dataSource.fetchSections()
                }
            }
            .listStyle(.plain)
            .navigationTitle("所有版面")
            .navigationDestination(for: SMSection.self) { section in
                BoardListView(section: section)
            }
        }
        
    }
}

struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        SectionListView()
    }
}
