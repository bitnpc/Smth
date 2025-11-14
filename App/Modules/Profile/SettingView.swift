//
//  SettingView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/30.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var fontSettings: FontSettings

    var body: some View {
        List {
            Section {
                Text("精简")
                Text("图文")
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
