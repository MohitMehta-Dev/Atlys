//
//  PageIndicatorView.swift
//  Atlys_Assignment
//
//  Created by Mohit Mehta on 20/04/25.
//

import SwiftUI

/// A view that displays a row of dots indicating the current page in a paginated interface
/// such as a carousel or page view.
///
/// Each page is represented by a circle, with the current page highlighted with a darker color.
/// The indicator animates smoothly when the current page changes.
///
/// Usage example:
/// ```
/// PageIndicatorView(numberOfPages: 5, currentPage: 2)
/// ```
struct PageIndicatorView: View {
    /// The total number of pages to display indicators for
    let numberOfPages: Int
    
    /// The index of the currently selected page (zero-based)
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.gray : Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .animation(.spring(), value: currentPage)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .clipShape(Capsule())
    }
}

