//
//  SettingView.swift
//  Smth
//
//  设置页面视图，提供应用设置功能
//  Created by tony
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var fontSettings: FontSettings
    @EnvironmentObject private var layoutSettings: LayoutSettings

    var body: some View {
        List {
            Section {
                Picker("页面布局", selection: $layoutSettings.selectedMode) {
                    ForEach(LayoutMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("layoutModePicker")
                Text("当前模式：\(layoutSettings.selectedMode.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("页面布局")
            }
            Section {
                Picker("阅读字号", selection: $fontSettings.selectedOption) {
                    ForEach(FontSizeOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("fontSizePicker")
                Text("当前字号：\(fontSettings.selectedOption.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section {
                Button("退出登录", role: .destructive) {
                    dismiss()
                    DispatchQueue.main.async {
                        Account.logout()
                    }
                }
            }
        }
        .navigationTitle("设置")
    }
}
