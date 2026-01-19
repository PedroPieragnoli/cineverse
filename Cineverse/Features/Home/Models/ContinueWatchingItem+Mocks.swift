//
//  ContinueWatchingItem+Mocks.swift
//  Cineverse
//

#if DEBUG
extension ContinueWatchingItem {
    static let mock = ContinueWatchingItem(
        movie: .mock,
        progress: 0.45,
        remainingSeconds: 45 * 60
    )

    static let mockArray: [ContinueWatchingItem] = [
        ContinueWatchingItem(
            movie: .mock,
            progress: 0.45,
            remainingSeconds: 45 * 60
        ),
        ContinueWatchingItem(
            movie: .mockMario,
            progress: 0.80,
            remainingSeconds: 12 * 60
        ),
        ContinueWatchingItem(
            movie: .mockShazam,
            progress: 0.15,
            remainingSeconds: (1 * 60 + 50) * 60
        ),
        ContinueWatchingItem(
            movie: .mockAvatar,
            progress: 0.60,
            remainingSeconds: (1 * 60 + 20) * 60
        )
    ]
}
#endif
