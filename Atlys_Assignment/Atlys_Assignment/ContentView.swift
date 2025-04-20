//
//  ContentView.swift
//  Atlys_Assignment
//
//  Created by Mohit Mehta on 20/04/25.
//

import SwiftUI

/// A view that demonstrates the usage of the CarouselView component
/// with sample carousel items.
///
/// This view serves as an example of how to integrate the CarouselView
/// into a larger application interface, providing it with data and
/// configuring its appearance.
struct ContentView: View {
    /// Sample data items for the carousel
    /// In a real application, this might come from a data source or model
    let carouselItems = [
        CarouselItem(imageName: "img1"),
        CarouselItem(imageName: "img2"),
        CarouselItem(imageName: "img1")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header content can be added here
            
            // Carousel view - adapts to available space
            CarouselView(items: carouselItems) { item in
                VStack {
                    Image(item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            // Footer content can be added here
        }
        .frame(height: 250)
    }
}


// MARK: - Preview
struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
            ContentView()
    }
}
