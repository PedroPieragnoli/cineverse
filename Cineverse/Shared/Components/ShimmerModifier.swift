//
//  ShimmerModifier.swift
//  Cineverse
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    // MARK: - Layout Constants

    private enum Layout {
        static let gradientBandWidth: CGFloat = 0.3
    }

    // MARK: - Properties

    let delay: TimeInterval

    @State private var phase: CGFloat = -1

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .overlay { shimmerOverlay }
            .mask { content }
            .onAppear(perform: startAnimation)
    }

    // MARK: - Subviews

    private var shimmerOverlay: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            LinearGradient(
                stops: [
                    .init(color: DesignSystem.Colors.shimmerLow, location: 0),
                    .init(
                        color: DesignSystem.Colors.shimmerHigh,
                        location: Layout.gradientBandWidth / 2
                    ),
                    .init(color: DesignSystem.Colors.shimmerLow, location: Layout.gradientBandWidth)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: width * 2)
            .offset(x: phase * width)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Animation

    private func startAnimation() {
        Task { @MainActor in
            if delay > 0 {
                try? await Task.sleep(for: .seconds(delay))
            }
            withAnimation(
                .linear(duration: DesignSystem.Animation.shimmerDuration)
                    .repeatForever(autoreverses: false)
            ) {
                phase = 1
            }
        }
    }
}

// MARK: - View Extension

extension View {
    func shimmer(delay: TimeInterval = 0) -> some View {
        modifier(ShimmerModifier(delay: delay))
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Rectangle") {
    ZStack {
        Color.black.ignoresSafeArea()
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
            .fill(DesignSystem.Colors.posterPlaceholder)
            .frame(width: 75, height: 112)
            .shimmer()
    }
}

#Preview("Staggered") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.skeleton, style: .continuous)
                .fill(DesignSystem.Colors.posterPlaceholder)
                .frame(width: 200, height: 12)
                .shimmer()

            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.skeleton, style: .continuous)
                .fill(DesignSystem.Colors.posterPlaceholder)
                .frame(width: 140, height: 12)
                .shimmer(delay: 0.1)

            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.skeleton, style: .continuous)
                .fill(DesignSystem.Colors.posterPlaceholder)
                .frame(width: 100, height: 10)
                .shimmer(delay: 0.2)
        }
        .padding()
    }
}
#endif
