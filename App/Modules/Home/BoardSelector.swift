//
//  BoardSelector.swift
//  Smth
//
//  Created by 仝超 on 2025/11/12.
//

import SwiftUI

struct BoardSelector: View {
    @Environment(\.colorScheme) private var colorScheme

    let boards: [Board]
    @Binding var selectedIndex: Int

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.compactSpacing) {
                    ForEach(Array(boards.enumerated()), id: \.element.id) { index, board in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedIndex = index
                            }
                        } label: {
                            selectorChip(for: board.title, isSelected: index == selectedIndex)
                        }
                        .buttonStyle(.plain)
                        .id(board.id)
                    }
                }
                .padding(.horizontal, AppTheme.verticalSpacing)
                .padding(.vertical, AppTheme.compactSpacing)
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                    .fill(
                        AppTheme.surfaceBackground(for: colorScheme).opacity(0.92)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous)
                            .stroke(AppTheme.borderColor(for: colorScheme).opacity(0.6))
                    )
                    .shadow(color: AppTheme.shadowColor(for: colorScheme).opacity(0.12), radius: 18, y: 10)
            )
            .padding(.horizontal, AppTheme.verticalSpacing)
            .padding(.top, AppTheme.verticalSpacing)
            .onChange(of: selectedIndex, { oldValue, newValue in
                guard boards.indices.contains(newValue) else { return }
                let board = boards[newValue]
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(board.id, anchor: .center)
                }
            })
        }
    }

    @ViewBuilder
    private func selectorChip(for title: String, isSelected: Bool) -> some View {
        let accent = AppTheme.accentColor(for: colorScheme)
        Text(title)
            .font(.system(.subheadline, design: .rounded).weight(.semibold))
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? Color.white : accent)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        isSelected
                            ? accent
                            : accent.opacity(0.12)
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(accent.opacity(isSelected ? 0 : 0.35), lineWidth: 1)
                    )
                    .shadow(color: accent.opacity(isSelected ? 0.35 : 0.0), radius: isSelected ? 12 : 0, y: isSelected ? 6 : 0)
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
