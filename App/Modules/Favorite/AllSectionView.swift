//
//  AllSectionView.swift
//  Smth
//
//  所有版块页面视图，展示完整的版块层级结构
//  Created by tony
//

import SwiftUI

struct AllSectionView: View {
    @StateObject private var viewModel: AllSectionsViewModel

    @MainActor
    init(viewModel: AllSectionsViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? AllSectionsViewModel())
    }
    
    var body: some View {
        List {
            ForEach(viewModel.sections, id: \.id) { section in
                NavigationLink(value: section) {
                    Text(section.name)
                }
            }
            if viewModel.sections.isEmpty {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                } else {
                    Text("暂无版面数据")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear() {
            Task {
                await viewModel.loadSectionsIfNeeded()
            }
        }
        .listStyle(.plain)
        .navigationTitle("所有版面")
    }
}

