//
//  DetailHeroAnimatorTests.swift
//  CineverseTests
//

import CoreGraphics
import Foundation
import Testing
@testable import Cineverse

@MainActor
struct DetailHeroAnimatorTests {

    // MARK: - Opening

    @Test("beginOpening without hero reveals detail immediately and emits an entrance token")
    func beginOpeningWithoutHeroRevealsImmediately() {
        let animator = DetailHeroAnimator()

        animator.beginOpening(useHero: false, payload: nil)

        #expect(animator.isAwaitingOpeningDestinationFrame == false)
        #expect(animator.detailRevealOpacity == 1)
        #expect(animator.detailEntranceToken != nil)
        #expect(animator.heroOverlayPayload == nil)
    }

    @Test("beginOpening with hero stores the payload and defers the detail reveal")
    func beginOpeningWithHeroDefersReveal() {
        let animator = DetailHeroAnimator()
        let payload = makePayload()

        animator.beginOpening(useHero: true, payload: payload)

        #expect(animator.isAwaitingOpeningDestinationFrame)
        #expect(animator.detailRevealOpacity == 0)
        #expect(animator.detailEntranceToken == nil)
        #expect(animator.heroOverlayPayload?.posterURL == payload.posterURL)
        #expect(animator.heroOverlayPayload?.currentFrame == payload.currentFrame)
    }

    @Test("beginOpening replaces an existing overlay payload")
    func beginOpeningReplacesPreviousPayload() {
        let animator = DetailHeroAnimator()
        animator.beginOpening(useHero: true, payload: makePayload())

        let newPayload = makePayload(
            posterURLString: "https://example.com/other.jpg",
            currentFrame: CGRect(x: 10, y: 10, width: 50, height: 75)
        )
        animator.beginOpening(useHero: true, payload: newPayload)

        #expect(animator.heroOverlayPayload?.posterURL == newPayload.posterURL)
        #expect(animator.heroOverlayPayload?.currentFrame == newPayload.currentFrame)
    }

    // MARK: - consumePosterFrameAwaiting

    @Test("consumePosterFrameAwaiting returns true once and clears the flag")
    func consumePosterFrameAwaitingIsIdempotent() {
        let animator = DetailHeroAnimator()
        animator.beginOpening(useHero: true, payload: makePayload())

        #expect(animator.consumePosterFrameAwaiting())
        #expect(animator.isAwaitingOpeningDestinationFrame == false)
        #expect(animator.consumePosterFrameAwaiting() == false)
    }

    @Test("consumePosterFrameAwaiting returns false when not awaiting a frame")
    func consumePosterFrameAwaitingWhenNotAwaiting() {
        let animator = DetailHeroAnimator()

        #expect(animator.consumePosterFrameAwaiting() == false)
        #expect(animator.isAwaitingOpeningDestinationFrame == false)
    }

    // MARK: - Closing

    @Test("beginClosing without payload clears overlay and resets the detail reveal")
    func beginClosingWithoutPayloadResetsReveal() {
        let animator = DetailHeroAnimator()
        animator.beginOpening(useHero: false, payload: nil)

        animator.beginClosing(transitionPayload: nil)

        #expect(animator.heroOverlayPayload == nil)
        #expect(animator.detailRevealOpacity == 0)
        #expect(animator.detailEntranceToken == nil)
        #expect(animator.isAwaitingOpeningDestinationFrame == false)
    }

    @Test("beginClosing with a payload stores it for the hero dismiss animation")
    func beginClosingWithPayloadStoresIt() {
        let animator = DetailHeroAnimator()
        animator.beginOpening(useHero: false, payload: nil)
        #expect(animator.detailRevealOpacity == 1)

        let closingPayload = makePayload()
        animator.beginClosing(transitionPayload: closingPayload)

        #expect(animator.heroOverlayPayload?.posterURL == closingPayload.posterURL)
        #expect(animator.detailEntranceToken == nil)
        #expect(animator.isAwaitingOpeningDestinationFrame == false)
        #expect(animator.detailRevealOpacity == 1)
    }

    // MARK: - animateHero (reduceMotion)

    @Test("animateHero with reduceMotion snaps to target and fires completion synchronously")
    func animateHeroReduceMotionFiresSynchronously() {
        let animator = DetailHeroAnimator()
        animator.beginOpening(useHero: true, payload: makePayload())
        let completions = Box(0)

        let targetFrame = CGRect(x: 30, y: 40, width: 200, height: 300)
        let targetRadius: CGFloat = 12

        animator.animateHero(
            to: targetFrame,
            targetCornerRadius: targetRadius,
            kind: .presenting,
            reduceMotion: true
        ) {
            completions.value += 1
        }

        #expect(completions.value == 1)
        #expect(animator.heroOverlayPayload?.currentFrame == targetFrame)
        #expect(animator.heroOverlayPayload?.currentCornerRadius == targetRadius)
    }

    // MARK: - scheduleDismissLeadIn

    @Test("scheduleDismissLeadIn fires the action after the lead-in delay")
    func scheduleDismissLeadInFiresAction() async throws {
        let animator = DetailHeroAnimator()
        let fired = Box(false)

        animator.scheduleDismissLeadIn { fired.value = true }

        try await Task.sleep(for: .seconds(DetailHeroAnimator.Constants.dismissHeroLeadInDelay + 0.1))

        #expect(fired.value)
    }

    @Test("cancelDismissLeadIn prevents the pending action from firing")
    func cancelDismissLeadInInvalidates() async throws {
        let animator = DetailHeroAnimator()
        let fired = Box(false)

        animator.scheduleDismissLeadIn { fired.value = true }
        animator.cancelDismissLeadIn()

        try await Task.sleep(for: .seconds(DetailHeroAnimator.Constants.dismissHeroLeadInDelay + 0.1))

        #expect(fired.value == false)
    }

    @Test("cancelAll cancels a pending dismiss lead-in")
    func cancelAllCancelsPendingLeadIn() async throws {
        let animator = DetailHeroAnimator()
        let fired = Box(false)

        animator.scheduleDismissLeadIn { fired.value = true }
        animator.cancelAll()

        try await Task.sleep(for: .seconds(DetailHeroAnimator.Constants.dismissHeroLeadInDelay + 0.1))

        #expect(fired.value == false)
    }

    @Test("rescheduling dismiss lead-in supersedes the previous request")
    func rescheduleDismissLeadInSupersedes() async throws {
        let animator = DetailHeroAnimator()
        let firstFired = Box(false)
        let secondFired = Box(false)

        animator.scheduleDismissLeadIn { firstFired.value = true }
        animator.scheduleDismissLeadIn { secondFired.value = true }

        try await Task.sleep(for: .seconds(DetailHeroAnimator.Constants.dismissHeroLeadInDelay + 0.1))

        #expect(firstFired.value == false)
        #expect(secondFired.value)
    }

    // MARK: - scheduleDetailReveal

    @Test("scheduleDetailReveal reveals detail and emits an entrance token after the delay")
    func scheduleDetailRevealRevealsAndEmitsToken() async throws {
        let animator = DetailHeroAnimator()
        animator.beginOpening(useHero: true, payload: makePayload())

        animator.scheduleDetailReveal(after: 0.02)
        try await Task.sleep(for: .seconds(0.2))

        #expect(animator.detailRevealOpacity == 1)
        #expect(animator.detailEntranceToken != nil)
    }

    @Test("cancelDetailEntrance invalidates an in-flight detail reveal")
    func cancelDetailEntranceInvalidatesReveal() async throws {
        let animator = DetailHeroAnimator()
        animator.beginOpening(useHero: true, payload: makePayload())

        animator.scheduleDetailReveal(after: 0.1)
        animator.cancelDetailEntrance()

        try await Task.sleep(for: .seconds(0.2))

        #expect(animator.detailRevealOpacity == 0)
        #expect(animator.detailEntranceToken == nil)
    }

    @Test("beginOpening cancels a previously scheduled detail reveal")
    func beginOpeningCancelsPreviousDetailReveal() async throws {
        let animator = DetailHeroAnimator()
        animator.beginOpening(useHero: true, payload: makePayload())
        animator.scheduleDetailReveal(after: 0.1)

        animator.beginOpening(useHero: true, payload: makePayload())

        try await Task.sleep(for: .seconds(0.2))

        #expect(animator.detailRevealOpacity == 0)
        #expect(animator.detailEntranceToken == nil)
    }

    // MARK: - clearOverlay

    @Test("clearOverlay removes the stored payload")
    func clearOverlayRemovesPayload() {
        let animator = DetailHeroAnimator()
        animator.beginOpening(useHero: true, payload: makePayload())

        animator.clearOverlay()

        #expect(animator.heroOverlayPayload == nil)
    }

    // MARK: - Helpers

    private func makePayload(
        posterURLString: String = "https://example.com/poster.jpg",
        currentFrame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 150),
        currentCornerRadius: CGFloat = 8
    ) -> DetailHeroAnimator.HeroOverlayPayload {
        DetailHeroAnimator.HeroOverlayPayload(
            posterURL: URL(string: posterURLString),
            currentFrame: currentFrame,
            currentCornerRadius: currentCornerRadius
        )
    }
}

@MainActor
private final class Box<T> {
    var value: T
    init(_ value: T) { self.value = value }
}
