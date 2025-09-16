//
//  DesignSystem.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI

// MARK: - Semantic Color Palette
extension Color {
    static let primaryBlue = Color(red: 0.118, green: 0.227, blue: 0.541) // #1E3A8A
    static let secondaryEmerald = Color(red: 0.063, green: 0.725, blue: 0.506) // #10B981
    static let warningAmber = Color(red: 0.961, green: 0.620, blue: 0.043) // #F59E0B
    static let cardBackground = Color(.systemBackground).opacity(0.95)
    static let surfaceSecondary = Color(.secondarySystemBackground).opacity(0.05)
}

// MARK: - Elevation System
enum Elevation {
    case low, medium, high
    
    var shadowModifier: some ViewModifier {
        switch self {
        case .low:
            return ShadowModifier(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        case .medium:
            return ShadowModifier(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        case .high:
            return ShadowModifier(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
    }
}

struct ShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content.shadow(color: color, radius: radius, x: x, y: y)
    }
}

// MARK: - Reusable Style Modifiers
struct CardStyle: ViewModifier {
    let elevation: Elevation
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBackground)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .cornerRadius(12)
                    )
            )
            .modifier(elevation.shadowModifier)
    }
}

struct StatusBadgeStyle: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: Color.primaryBlue.opacity(0.25), radius: 8, x: 0, y: 3)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(elevation: Elevation = .medium) -> some View {
        modifier(CardStyle(elevation: elevation))
    }
    
    func statusBadge(color: Color) -> some View {
        modifier(StatusBadgeStyle(color: color))
    }
    
    func primaryButton() -> some View {
        modifier(PrimaryButtonStyle())
    }
    
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: style)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Typography Scale
extension Font {
    static let metricValue = Font.largeTitle.weight(.bold)
    static let metricLabel = Font.caption.weight(.medium)
    static let sectionHeader = Font.headline.weight(.semibold)
    static let cardTitle = Font.body.weight(.semibold)
    static let cardSubtitle = Font.footnote.weight(.medium)
}

// MARK: - Spacing Constants
struct Spacing {
    static let container: CGFloat = 16
    static let card: CGFloat = 12
    static let inline: CGFloat = 8
    static let tight: CGFloat = 4
}

// MARK: - Corner Radius Constants
struct CornerRadius {
    static let card: CGFloat = 12
    static let button: CGFloat = 8
    static let pill: CGFloat = 20
    static let small: CGFloat = 6
}
