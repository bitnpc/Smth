//
//  LayoutSettings.swift
//  Smth
//
//  布局设置管理，提供页面布局模式设置功能
//  Created by tony
//

import SwiftUI

enum LayoutMode: String, CaseIterable, Identifiable {
    case compact  // 精简模式
    case imageText  // 图文模式

    var id: String { rawValue }

    var title: String {
        switch self {
        case .compact: return "精简"
        case .imageText: return "图文"
        }
    }

    var showImages: Bool {
        switch self {
        case .compact: return false
        case .imageText: return true
        }
    }
}

@MainActor
final class LayoutSettings: ObservableObject {
    @Published var selectedMode: LayoutMode {
        didSet {
            if selectedMode != oldValue {
                storage.set(selectedMode.rawValue, forKey: storageKey)
            }
        }
    }

    private let storage: UserDefaults
    private let storageKey = "app.layout.mode"

    init(storage: UserDefaults = .standard) {
        self.storage = storage
        if let rawValue = storage.string(forKey: storageKey),
           let mode = LayoutMode(rawValue: rawValue) {
            selectedMode = mode
        } else {
            selectedMode = .imageText  // 默认图文模式
        }
    }

    var showImages: Bool {
        selectedMode.showImages
    }
}
