//
//  CarouselView.swift
//  Atlys_Assignment
//
//  Created by Mohit Mehta on 20/04/25.
//

import SwiftUI

/// A customizable carousel view that displays items in a horizontal scrollable layout
/// with scaling and z-index effects based on item position.
///
/// This carousel automatically centers items during scrolling and provides visual feedback
/// through scaling (items in center appear larger) and layering (items in center appear on top).
///
/// Usage example:
/// ```
/// CarouselView(items: myItems) { item in
///     MyItemView(item: item)
/// }
/// ```
struct CarouselView<Content: View, Item: Identifiable>: View {
    // MARK: - Properties

    /// The collection of items to display in the carousel
    private let items: [Item]
    
    /// The view builder closure that creates views for each item
    private let content: (Item) -> Content
    
    /// The aspect ratio (width/height) for each carousel item
    private let itemAspectRatio: CGFloat
    
    /// The maximum scale factor applied to the centered item
    private let maxScaleFactor: CGFloat
    
    /// The minimum scale factor applied to items furthest from center
    private let minScaleFactor: CGFloat
    
    /// The current scroll offset of the carousel
    @State private var offset: CGFloat = 0
    
    /// The current drag offset during a gesture
    @GestureState private var dragOffset: CGFloat = 0
    
    /// The index of the currently centered item
    @State private var currentIndex: Int = 0
    
    // MARK: - Initialization
    
    /// Creates a new carousel view with the specified items and configuration
    /// - Parameters:
    ///   - items: The collection of identifiable items to display
    ///   - itemAspectRatio: The width-to-height ratio for each item (default: 1.0)
    ///   - maxScaleFactor: The maximum scale factor for the centered item (default: 1.2)
    ///   - minScaleFactor: The minimum scale factor for non-centered items (default: 1.0)
    ///   - content: A view builder that creates the view for each item
    init(
        items: [Item],
        itemAspectRatio: CGFloat = 1.0,
        maxScaleFactor: CGFloat = 1.2,
        minScaleFactor: CGFloat = 1.0,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.itemAspectRatio = itemAspectRatio
        self.maxScaleFactor = maxScaleFactor
        self.minScaleFactor = minScaleFactor
        self.content = content
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                // Calculate dimensions
                let itemSize = calculateItemSize(in: geometry)
                let sideInset = (geometry.size.width - itemSize.width) / 2
                
                carouselItemsView(itemSize: itemSize, geometry: geometry)
                    .padding(.horizontal, sideInset)
                    .offset(x: calculateTotalOffset())
                    .gesture(createDragGesture(itemSize: itemSize))
                    .onAppear {
                        centerInitialItem(itemSize: itemSize)
                    }
            }
            PageIndicatorView(numberOfPages: items.count, currentPage: currentIndex)
                .padding(.vertical, 12)
        }
    }
    
    // MARK: - Helper Views
    
    /// Creates the horizontal stack of carousel items
    /// - Parameters:
    ///   - itemSize: The calculated size for each item
    ///   - geometry: The geometry proxy of the container
    /// - Returns: A view containing all carousel items with proper spacing and effects
    private func carouselItemsView(itemSize: CGSize, geometry: GeometryProxy) -> some View {
        HStack(spacing: itemSize.width/2) {
            ForEach(items) { item in
                content(item)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: itemSize.width, height: itemSize.height)
                    .scaleEffect(calculateScale(for: item, in: geometry, itemSize: itemSize))
                    .zIndex(calculateZIndex(for: item, in: geometry, itemSize: itemSize))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: offset)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Calculates the appropriate size for each carousel item based on container dimensions
    /// - Parameter geometry: The geometry proxy of the container
    /// - Returns: The size to use for each carousel item
    private func calculateItemSize(in geometry: GeometryProxy) -> CGSize {
        let width = min(geometry.size.width * 0.5, geometry.size.height * itemAspectRatio)
        return CGSize(width: width, height: width / itemAspectRatio)
    }
    
    /// Calculates the combined offset from static position and current drag
    /// - Returns: The total horizontal offset to apply to the carousel
    private func calculateTotalOffset() -> CGFloat {
        return offset + dragOffset
    }
    
    /// Centers the initial item when the carousel first appears
    /// - Parameter itemSize: The calculated size for each item
    private func centerInitialItem(itemSize: CGSize) {
        if !items.isEmpty {
            let initialIndex = min(items.count / 2, items.count - 1)
            let itemWidthWithSpacing = itemSize.width + itemSize.width/2
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                offset = -CGFloat(initialIndex) * itemWidthWithSpacing
                currentIndex = initialIndex
            }
        }
    }
    
    /// Calculates the z-index for an item based on its distance from center
    /// Items closer to center appear on top of items further from center
    /// - Parameters:
    ///   - item: The carousel item
    ///   - geometry: The container geometry
    ///   - itemSize: The calculated size of each item
    /// - Returns: A z-index value (higher values appear on top)
    private func calculateZIndex(for item: Item, in geometry: GeometryProxy, itemSize: CGSize) -> Double {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return 0.0 }
        
        // Calculate how centered this item is (0 = perfectly centered)
        let itemWidthWithSpacing = itemSize.width + itemSize.width/2
        let currentOffset = offset + dragOffset
        let itemPosition = -currentOffset - (CGFloat(index) * itemWidthWithSpacing)
        
        // Convert to a range from 0 (edge) to 1 (center)
        let distanceFromCenter = abs(itemPosition)
        let maxDistance = itemWidthWithSpacing/2
        
        // Items closer to center have higher z-index (1 at center, 0 at max distance)
        let normalizedDistance = min(distanceFromCenter / maxDistance, 1.0)
        return 1.0 - normalizedDistance
    }
    
    /// Calculates the scale factor for an item based on its distance from center
    /// Items closer to center appear larger than items further from center
    /// - Parameters:
    ///   - item: The carousel item
    ///   - geometry: The container geometry
    ///   - itemSize: The calculated size of each item
    /// - Returns: A scale factor between minScaleFactor and maxScaleFactor
    private func calculateScale(for item: Item, in geometry: GeometryProxy, itemSize: CGSize) -> CGFloat {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return minScaleFactor }
        
        // Calculate distance from center (in item units)
        let itemWidthWithSpacing = itemSize.width + itemSize.width/2
        let currentOffset = offset + dragOffset
        let itemOffset = CGFloat(index) * itemWidthWithSpacing
        let distanceFromCenter = abs(currentOffset + itemOffset)
        
        // Scale based on distance - linear interpolation between max and min scale
        let maxDistance = itemWidthWithSpacing/2
        let normalizedDistance = min(distanceFromCenter / maxDistance, 1.0)
        
        return maxScaleFactor - normalizedDistance * (maxScaleFactor - minScaleFactor)
    }
    
    /// Creates a drag gesture for the carousel that updates position based on user interaction
    /// - Parameter itemSize: The calculated size for each item
    /// - Returns: A drag gesture that updates the carousel position
    private func createDragGesture(itemSize: CGSize) -> some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let itemWidthWithSpacing = itemSize.width + itemSize.width/2
                
                // Calculate predicted final position
                let predictedOffset = offset + value.predictedEndTranslation.width
                
                // Determine closest item index
                let targetIndex = -Int(round(predictedOffset / itemWidthWithSpacing))
                let boundedIndex = min(max(0, targetIndex), items.count - 1)
                
                // Smoothly animate to the final position
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    offset = -CGFloat(boundedIndex) * itemWidthWithSpacing
                    currentIndex = boundedIndex
                }
            }
    }
}

