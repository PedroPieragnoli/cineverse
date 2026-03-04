//
//  MovieCastMember+Mocks.swift
//  Cineverse
//

#if DEBUG
import Foundation

extension MovieCastMember {
    static let mock = MovieCastMember(
        id: 1136406,
        name: "Tom Holland",
        character: "Peter Parker / Spider-Man",
        profilePath: "/bBRlrpJm9XkNSg0YT5LCaxqoFMz.jpg"
    )

    static let mockWithoutPhoto = MovieCastMember(
        id: 2,
        name: "Unknown Actor",
        character: "Extra",
        profilePath: nil
    )

    static let mockArray = [
        MovieCastMember.mock,
        MovieCastMember(
            id: 71580,
            name: "Benedict Cumberbatch",
            character: "Dr. Stephen Strange",
            profilePath: "/fBEucxECxOKjnO3gdoKKejXVMEv.jpg"
        ),
        MovieCastMember(
            id: 505710,
            name: "Zendaya",
            character: "MJ",
            profilePath: "/tyNYAiMN26ePIjQz5bnUaGMSuR2.jpg"
        ),
        MovieCastMember.mockWithoutPhoto
    ]
}
#endif
