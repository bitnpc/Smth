//
//  AppTheme.swift
//  Smth
//
//  应用主题配置，定义颜色、间距、圆角等 UI 样式常量
//  Created by tony
//

import SwiftUI

enum AppTheme {
    static let cardCornerRadius: CGFloat = 18
    static let smallCornerRadius: CGFloat = 12
    static let verticalSpacing: CGFloat = 16
    static let compactSpacing: CGFloat = 8

    static func scaffoldBackground(for colorScheme: ColorScheme) -> LinearGradient {
        let lightColors = [
            Color(red: 0.96, green: 0.97, blue: 1.0),
            Color(red: 0.93, green: 0.95, blue: 0.99)
        ]
        let darkColors = [
            Color(red: 0.08, green: 0.09, blue: 0.13),
            Color(red: 0.03, green: 0.04, blue: 0.08)
        ]
        return LinearGradient(
            colors: colorScheme == .dark ? darkColors : lightColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func surfaceBackground(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return Color(red: 0.13, green: 0.15, blue: 0.21)
        } else {
            return Color(red: 0.99, green: 1.0, blue: 1.0)
        }
    }

    static func subduedSurface(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return Color(red: 0.18, green: 0.19, blue: 0.24)
        } else {
            return Color(red: 0.95, green: 0.96, blue: 0.99)
        }
    }

    static func borderColor(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return Color.white.opacity(0.08)
        } else {
            return Color.black.opacity(0.06)
        }
    }

    static func shadowColor(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return Color.black.opacity(0.5)
        } else {
            return Color.black.opacity(0.12)
        }
    }

    static func accentColor(for colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return Color(red: 0.46, green: 0.65, blue: 1.0)
        } else {
            return Color(red: 0.29, green: 0.47, blue: 0.95)
        }
    }
}

private struct ScaffoldBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                AppTheme.scaffoldBackground(for: colorScheme)
                    .ignoresSafeArea()
            )
    }
}

private struct SurfaceBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var subdued: Bool

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                    .fill(subdued ? AppTheme.subduedSurface(for: colorScheme) : AppTheme.surfaceBackground(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                            .stroke(AppTheme.borderColor(for: colorScheme))
                    )
            )
            .shadow(
                color: AppTheme.shadowColor(for: colorScheme).opacity(subdued ? 0.18 : 0.22),
                radius: subdued ? 12 : 16,
                y: subdued ? 4 : 10
            )
    }
}

extension View {
    func smthScaffoldBackground() -> some View {
        modifier(ScaffoldBackgroundModifier())
    }

    func smthSurfaceBackground(subdued: Bool = false) -> some View {
        modifier(SurfaceBackgroundModifier(subdued: subdued))
    }
}


