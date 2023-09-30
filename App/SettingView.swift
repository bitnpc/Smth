//
//  SettingView.swift
//  Smth
//
//  Created by Tony Clark on 2023/9/30.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        List {
            Section {
                Text("精简")
                Text("图文")
            } header: {
                Text("页面布局")
            }
            Section {
                Text("阅读字号")
            }
            Section {
                Button("退出登录", role: .destructive) {
                    Account.logout()
                }
            }
        }.navigationTitle("设置")
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
