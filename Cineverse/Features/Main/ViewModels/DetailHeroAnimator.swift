import Foundation
import SwiftUI

@Observable
@MainActor
final class DetailHeroAnimator {
    enum Constants {
        static let heroInfoLeadInDelay: TimeInterval = 0.22
        static let detailRevealFadeDuration: TimeInterval = 0.16
        static let heroDismissDuration: TimeInterval = 0.24
        static let dismissHeroLeadInDelay: TimeInterval = 0.07
        static let heroPresentResponse: Double = 0.46
        static let heroPresentDamping: Double = 0.86
    }

    struct HeroOverlayPayload {
        let posterURL: URL?
        var currentFrame: CGRect
        var currentCornerRadius: CGFloat
    }

    enum HeroOverlayAnimationKind {
        case presenting
        case dismissing

        var animation: Animation {
            switch self {
            case .presenting:
                return .spring(
                    response: Constants.heroPresentResponse,
                    dampingFraction: Constants.heroPresentDamping
                )
            case .dismissing:
                return .easeOut(duration: Constants.heroDismissDuration)
            }
        }
    }

    // MARK: - Observed state

    var heroOverlayPayload: HeroOverlayPayload?
    var detailEntranceToken: UUID?
    var detailRevealOpacity: CGFloat = 0
    var isAwaitingOpeningDestinationFrame = false

    // MARK: - Cancellation tokens

    private var heroAnimationGeneration = 0
    private var detailEntranceGeneration = 0
    private var dismissLeadInGeneration = 0

    // MARK: - Opening

    func beginOpening(useHero: Bool, payload: HeroOverlayPayload?) {
        cancelAll()
        isAwaitingOpeningDestinationFrame = useHero
        detailRevealOpacity = useHero ? 0 : 1
        detailEntranceToken = nil

        guard useHero, let payload else {
            heroOverlayPayload = nil
            detailEntranceToken = UUID()
            return
        }

        heroOverlayPayload = payload
    }

    func consumePosterFrameAwaiting() -> Bool {
        guard isAwaitingOpeningDestinationFrame else {
            return false
        }

        isAwaitingOpeningDestinationFrame = false
        return true
    }

    // MARK: - Closing

    func beginClosing(transitionPayload: HeroOverlayPayload?) {
        isAwaitingOpeningDestinationFrame = false
        cancelDetailEntrance()
        detailEntranceToken = nil

        guard let transitionPayload else {
            clearOverlay(cancelAnimation: true)
            detailRevealOpacity = 0
            return
        }

        heroOverlayPayload = transitionPayload
    }

    // MARK: - Animation

    func animateHero(
        to targetFrame: CGRect,
        targetCornerRadius: CGFloat,
        kind: HeroOverlayAnimationKind,
        reduceMotion: Bool,
        completion: @escaping @MainActor () -> Void
    ) {
        cancelHeroAnimation()

        if reduceMotion {
            heroOverlayPayload?.currentFrame = targetFrame
            heroOverlayPayload?.currentCornerRadius = targetCornerRadius
            completion()
            return
        }

        heroAnimationGeneration += 1
        let generation = heroAnimationGeneration

        withAnimation(kind.animation, completionCriteria: .logicallyComplete) {
            heroOverlayPayload?.currentFrame = targetFrame
            heroOverlayPayload?.currentCornerRadius = targetCornerRadius
        } completion: {
            guard generation == self.heroAnimationGeneration else {
                return
            }

            completion()
        }
    }

    func scheduleDetailReveal(after delay: TimeInterval) {
        detailEntranceGeneration += 1
        let generation = detailEntranceGeneration

        Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(delay))
            } catch {
                return // Cancelled by cancelDetailEntrance(); abort silently.
            }

            guard generation == self.detailEntranceGeneration else {
                return
            }

            withAnimation(.easeOut(duration: Constants.detailRevealFadeDuration)) {
                self.detailRevealOpacity = 1
            }

            self.detailEntranceToken = UUID()
        }
    }

    func scheduleDismissLeadIn(perform action: @escaping @MainActor () -> Void) {
        dismissLeadInGeneration += 1
        let generation = dismissLeadInGeneration

        Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(Constants.dismissHeroLeadInDelay))
            } catch {
                return
            }

            guard generation == self.dismissLeadInGeneration else {
                return
            }

            action()
        }
    }

    // MARK: - Cancellation

    func cancelAll() {
        cancelHeroAnimation()
        cancelDetailEntrance()
        cancelDismissLeadIn()
    }

    func cancelHeroAnimation() {
        heroAnimationGeneration += 1
    }

    func cancelDetailEntrance() {
        detailEntranceGeneration += 1
    }

    func cancelDismissLeadIn() {
        dismissLeadInGeneration += 1
    }

    func clearOverlay(cancelAnimation: Bool = false) {
        if cancelAnimation {
            cancelHeroAnimation()
        }

        heroOverlayPayload = nil
    }
}
