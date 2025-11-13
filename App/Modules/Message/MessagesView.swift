//
//  MessagesView.swift
//  Smth
//
//  Created by 仝超 on 2025/11/12.
//

import SwiftUI

struct MessagesView: View {
    @State private var selection: MessageTab = .inbox

    var body: some View {
        VStack(spacing: 0) {
            Picker("消息类型", selection: $selection) {
                ForEach(MessageTab.allCases, id: \.self) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            List {
                ForEach(1...12, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(selection.title) · 消息 \(index)")
                            .font(.headline)
                        Text("这里展示示例消息内容，真实数据接入后可替换。")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    private enum MessageTab: CaseIterable {
        case inbox
        case reply
        case like
        case mention

        var title: String {
            switch self {
            case .inbox: return "收件箱"
            case .reply: return "回复我的"
            case .like: return "Like我的"
            case .mention: return "@我的"
            }
        }
    }
}

#Preview {
    MessagesView()
}
