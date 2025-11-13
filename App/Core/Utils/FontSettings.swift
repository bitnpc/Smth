//
//  FontSettings.swift
//  Smth
//
//  Created by GPT-5 Codex on 2025/11/13.
//

import SwiftUI

enum FontSizeOption: String, CaseIterable, Identifiable {
    case small
    case standard
    case large
    case extraLarge

    var id: String { rawValue }

    var title: String {
        switch self {
        case .small: return "小"
        case .standard: return "标准"
        case .large: return "大"
        case .extraLarge: return "特大"
        }
    }

    var dynamicTypeSize: DynamicTypeSize {
        switch self {
        case .small: return .xSmall
        case .standard: return .medium
        case .large: return .accessibility2
        case .extraLarge: return .accessibility4
        }
    }
}

@MainActor
final class FontSettings: ObservableObject {
    @Published var selectedOption: FontSizeOption {
        didSet {
            if selectedOption != oldValue {
                storage.set(selectedOption.rawValue, forKey: storageKey)
            }
        }
    }

    private let storage: UserDefaults
    private let storageKey = "app.font.size.option"

    init(storage: UserDefaults = .standard) {
        self.storage = storage
        if let rawValue = storage.string(forKey: storageKey),
           let option = FontSizeOption(rawValue: rawValue) {
            selectedOption = option
        } else {
            selectedOption = .standard
        }
    }

    var dynamicTypeSize: DynamicTypeSize {
        selectedOption.dynamicTypeSize
    }
}


