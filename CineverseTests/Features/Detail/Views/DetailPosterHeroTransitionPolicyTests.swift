//
//  DetailPosterHeroTransitionPolicyTests.swift
//  CineverseTests
//

import CoreGraphics
import Testing
@testable import Cineverse

struct DetailPosterHeroTransitionPolicyTests {
    private static let validFrame = CGRect(x: 24, y: 180, width: 120, height: 180)
    private static let zeroWidthFrame = CGRect(x: 24, y: 180, width: 0, height: 180)
    private static let zeroHeightFrame = CGRect(x: 24, y: 180, width: 120, height: 0)

    static let scenarios: [(DetailRoute.Source, CGRect?, Bool, Bool)] = [
        (.posterCard, validFrame, false, true),
        (.posterCard, validFrame, true, false),
        (.posterCard, nil, false, false),
        (.posterCard, zeroWidthFrame, false, false),
        (.posterCard, zeroHeightFrame, false, false),
        (.hero, validFrame, false, false),
        (.hero, nil, false, false),
        (.hero, validFrame, true, false)
    ]

    @Test(
        "Hero transition is enabled only for poster source with a positive frame and motion allowed",
        arguments: scenarios
    )
    func isEnabledMatrix(
        source: DetailRoute.Source,
        frame: CGRect?,
        reduceMotion: Bool,
        expected: Bool
    ) {
        let actual = DetailPosterHeroTransitionPolicy.isEnabled(
            source: source,
            sourcePosterFrame: frame,
            reduceMotion: reduceMotion
        )

        #expect(actual == expected)
    }
}
