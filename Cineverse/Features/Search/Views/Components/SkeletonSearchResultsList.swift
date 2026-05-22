//
//  SkeletonSearchResultsList.swift
//  Cineverse
//

import SwiftUI

struct SkeletonSearchResultsList: View {
    private enum Layout {
        static let rowCount = 4
    }

    var body: some View {
        ForEach(0..<Layout.rowCount, id: \.self) { index in
            SkeletonSearchResultRowView(showDivider: index < Layout.rowCount - 1)
        }
    }
}

#if DEBUG
#Preview {
    SkeletonSearchResultsList()
        .padding()
        .background(DesignSystem.Colors.background)
        .preferredColorScheme(.dark)
}
#endif
