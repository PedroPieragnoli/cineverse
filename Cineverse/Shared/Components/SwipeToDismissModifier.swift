//
//  SwipeToDismissModifier.swift
//  Cineverse
//

import SwiftUI

enum SwipeDismissState {
    case began
    case cancelled
    case committed
}

struct SwipeToDismissModifier: ViewModifier {
    private enum Layout {
        static let axisLockThreshold: CGFloat = 12
        static let dismissThreshold: CGFloat = 120
        static let predictedDismissThreshold: CGFloat = 250
        static let edgeWidth: CGFloat = 24
        static let dismissAnimationDuration: TimeInterval = 0.25
        static let minimumDragDistance: CGFloat = 10
        static let cancelSpringResponse: Double = 0.32
        static let cancelSpringDamping: Double = 0.82
    }

    private enum LockedAxis {
        case horizontal
        case vertical
    }

    let isScrolledToTop: Bool
    let isScrolledToBottom: Bool
    let containerSize: CGSize
    let onStateChange: (SwipeDismissState) -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragOffset: CGSize = .zero
    @State private var lockedAxis: LockedAxis?
    @State private var startedFromEdge = false
    @State private var underlayOpacity: CGFloat = 1
    @State private var isDismissGestureActive = false
    @State private var dismissAnimationGeneration = 0

    func body(content: Content) -> some View {
        ZStack {
            Color.black
                .opacity(underlayOpacity)
                .ignoresSafeArea()
                .mask(exposedAreaMask)

            content
                .offset(dragOffset)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(swipeGesture)
        .onDisappear {
            dismissAnimationGeneration += 1
            clearAxisLock()
            dragOffset = .zero
            underlayOpacity = 1
            clearDismissGesture()
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: Layout.minimumDragDistance)
            .onChanged { value in
                handleDragChanged(value)
            }
            .onEnded { value in
                handleDragEnded(value)
            }
    }

    @ViewBuilder
    private var exposedAreaMask: some View {
        if dragOffset.width > 0 {
            Rectangle()
                .frame(width: dragOffset.width, height: containerSize.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        } else if dragOffset.height > 0 {
            Rectangle()
                .frame(width: containerSize.width, height: dragOffset.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } else if dragOffset.height < 0 {
            Rectangle()
                .frame(width: containerSize.width, height: abs(dragOffset.height))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        } else {
            Color.clear
        }
    }

    private func handleDragChanged(_ value: DragGesture.Value) {
        if lockedAxis == nil {
            startedFromEdge = value.startLocation.x < Layout.edgeWidth
            lockedAxis = lockAxis(for: value.translation)
        }

        guard let lockedAxis else {
            resetDragProgress()
            return
        }

        switch lockedAxis {
        case .horizontal:
            handleHorizontalDrag(with: value.translation)
        case .vertical:
            handleVerticalDrag(with: value.translation)
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        guard let activeAxis = lockedAxis, isDismissGestureActive else {
            resetInteraction()
            return
        }

        if shouldDismiss(
            for: activeAxis,
            translation: value.translation,
            predictedEndTranslation: value.predictedEndTranslation
        ) {
            clearAxisLock()
            commitDismissGesture()
            performDismiss(for: activeAxis)
            return
        }

        clearAxisLock()
        cancelDismissGesture()

        withAnimation(.spring(response: Layout.cancelSpringResponse, dampingFraction: Layout.cancelSpringDamping)) {
            dragOffset = .zero
            underlayOpacity = 1
        }
    }

    private func handleHorizontalDrag(with translation: CGSize) {
        guard startedFromEdge else {
            resetDragProgress()
            return
        }

        let clampedWidth = max(0, translation.width)
        guard clampedWidth > 0 else {
            resetDragProgress()
            return
        }

        dragOffset = CGSize(width: clampedWidth, height: 0)
        updateUnderlayOpacity()
        beginDismissGesture()
    }

    private func handleVerticalDrag(with translation: CGSize) {
        let height = translation.height
        let isAllowed = (height > 0 && isScrolledToTop) || (height < 0 && isScrolledToBottom)
        guard height != 0, isAllowed else {
            resetDragProgress()
            return
        }
        dragOffset = CGSize(width: 0, height: height)
        updateUnderlayOpacity()
        beginDismissGesture()
    }

    private func lockAxis(for translation: CGSize) -> LockedAxis? {
        let horizontalDistance = abs(translation.width)
        let verticalDistance = abs(translation.height)

        guard max(horizontalDistance, verticalDistance) > Layout.axisLockThreshold else {
            return nil
        }

        return horizontalDistance > verticalDistance ? .horizontal : .vertical
    }

    private func shouldDismiss(
        for axis: LockedAxis,
        translation: CGSize,
        predictedEndTranslation: CGSize
    ) -> Bool {
        switch axis {
        case .horizontal:
            return crossesDismissThreshold(
                distance: translation.width,
                predicted: predictedEndTranslation.width
            )
        case .vertical:
            let sign: CGFloat = dragOffset.height > 0 ? 1 : -1
            return crossesDismissThreshold(
                distance: sign * translation.height,
                predicted: sign * predictedEndTranslation.height
            )
        }
    }

    private func crossesDismissThreshold(distance: CGFloat, predicted: CGFloat) -> Bool {
        distance > Layout.dismissThreshold || predicted > Layout.predictedDismissThreshold
    }

    private func performDismiss(for axis: LockedAxis) {
        let targetOffset: CGSize

        switch axis {
        case .horizontal:
            targetOffset = CGSize(width: containerSize.width, height: 0)
        case .vertical:
            targetOffset = CGSize(
                width: 0,
                height: dragOffset.height > 0 ? containerSize.height : -containerSize.height
            )
        }

        dismissAnimationGeneration += 1
        let animationToken = dismissAnimationGeneration

        if reduceMotion {
            dragOffset = targetOffset
            underlayOpacity = 0
            onDismiss()
            return
        }

        withAnimation(.easeOut(duration: Layout.dismissAnimationDuration)) {
            dragOffset = targetOffset
            underlayOpacity = 0
        } completion: {
            guard animationToken == dismissAnimationGeneration else {
                return
            }

            onDismiss()
        }
    }
}

private extension SwipeToDismissModifier {
    func updateUnderlayOpacity() {
        if dragOffset.width != 0 {
            underlayOpacity = 1 - min(abs(dragOffset.width) / max(containerSize.width, 1), 1)
            return
        }

        if dragOffset.height != 0 {
            underlayOpacity = 1 - min(abs(dragOffset.height) / max(containerSize.height, 1), 1)
            return
        }

        underlayOpacity = 1
    }

    func resetDragProgress() {
        dragOffset = .zero
        underlayOpacity = 1
        cancelDismissGesture()
    }

    func resetInteraction() {
        clearAxisLock()
        resetDragProgress()
    }

    func clearAxisLock() {
        lockedAxis = nil
        startedFromEdge = false
    }

    func beginDismissGesture() {
        guard !isDismissGestureActive else {
            return
        }

        isDismissGestureActive = true
        onStateChange(.began)
    }

    func cancelDismissGesture() {
        guard isDismissGestureActive else {
            return
        }

        isDismissGestureActive = false
        onStateChange(.cancelled)
    }

    func commitDismissGesture() {
        guard isDismissGestureActive else {
            return
        }

        isDismissGestureActive = false
        onStateChange(.committed)
    }

    func clearDismissGesture() {
        isDismissGestureActive = false
    }
}

extension View {
    func swipeToDismiss(
        isScrolledToTop: Bool,
        isScrolledToBottom: Bool,
        in containerSize: CGSize,
        onStateChange: @escaping (SwipeDismissState) -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        modifier(
            SwipeToDismissModifier(
                isScrolledToTop: isScrolledToTop,
                isScrolledToBottom: isScrolledToBottom,
                containerSize: containerSize,
                onStateChange: onStateChange,
                onDismiss: onDismiss
            )
        )
    }
}
