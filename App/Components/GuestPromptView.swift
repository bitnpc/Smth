//
//  GuestPromptView.swift
//  Smth
//
//  未登录提示视图组件，统一显示登录提示
//  Created by tony
//

import SwiftUI

struct GuestPromptView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String
    let onLogin: () -> Void
    
    init(
        icon: String = "person.crop.circle.badge.plus",
        title: String,
        subtitle: String,
        actionTitle: String = "立即登录",
        onLogin: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.onLogin = onLogin
    }
    
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(AppTheme.accentColor(for: colorScheme))
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onLogin) {
                Text(actionTitle)
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 48)
        .padding(.horizontal, 36)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .smthSurfaceBackground()
    }
}

