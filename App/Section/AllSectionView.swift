//
//  AllSectionView.swift
//  Smth
//
//  Created by tony on 2024/3/24.
//

import SwiftUI

struct AllSectionView: View {
    
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

