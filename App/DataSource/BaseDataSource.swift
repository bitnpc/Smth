//
//  BaseDataSource.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/28.
//

import Foundation

class BaseDataSource: ObservableObject {
    
    enum LoadState {
    case normal
    case loading
    case completed
    }
    
    @MainActor @Published var state: LoadState = .normal
}
