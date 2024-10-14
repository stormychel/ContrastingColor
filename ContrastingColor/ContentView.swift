//
//  ContentView.swift
//  ContrastingColor
//
//  Created by Michel Storms on 14/10/24.
//

import SwiftUI

extension Color {
    /// Returns a primary contrasting color based on the background color and ensures a minimum contrast ratio.
    var contrastingPrimary: Color {
        return contrastColor(threshold: 7.0) // Enforce a higher contrast ratio
    }
    
    /// Returns a secondary contrasting color with a lower threshold for contrast.
    var contrastingSecondary: Color {
        return contrastColor(threshold: 4.5) // WCAG AA for large text
    }
    
    /// Returns a contrasting color for links, typically a shade of blue or another standout color.
    var contrastingLink: Color {
        let linkBlue = Color.blue
        return linkBlue.hasGoodContrast(with: self, threshold: 4.5) ? linkBlue : .yellow
    }

    /// Determines the contrast color (black or white) based on the luminance of the color and a threshold.
    private func contrastColor(threshold: Double) -> Color {
        return self.isDark(threshold: threshold) ? .white : .black
    }

    /// Determines if the color is dark or light based on the luminance and a contrast ratio threshold.
    private func isDark(threshold: Double) -> Bool {
        let luminance = self.relativeLuminance
        return (luminance + 0.05) / (0.05) < threshold // Update condition for contrast
    }
    
    /// Calculates the relative luminance of the color based on the RGB values.
    private var relativeLuminance: Double {
        let components = self.colorComponents
        let rgb = components.map { component -> Double in
            return (component <= 0.03928) ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }
        // Using the luminance formula
        return 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]
    }

    /// Returns the RGBA components of the color as CGFloat values.
    private var colorComponents: [CGFloat] {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue, alpha]
    }
    
    /// Determines if a color has a good contrast with the background based on a threshold.
    private func hasGoodContrast(with backgroundColor: Color, threshold: Double) -> Bool {
        let foregroundLuminance = self.relativeLuminance
        let backgroundLuminance = backgroundColor.relativeLuminance
        let contrastRatio = (foregroundLuminance + 0.05) / (backgroundLuminance + 0.05)
        return contrastRatio >= threshold
    }
}

struct ContentView: View {
    @State private var backgroundColor: Color = .orange // Initial background color

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(backgroundColor.contrastingPrimary) // Using primary contrasting color

            Text("Hello, world!")
                .font(.title)
                .foregroundColor(backgroundColor.contrastingPrimary) // Using primary contrasting color

            Text("This is secondary text.")
                .foregroundColor(backgroundColor.contrastingSecondary) // Using secondary contrasting color

            Link("Click here", destination: URL(string: "https://example.com")!)
                .foregroundColor(backgroundColor.contrastingLink) // Using link contrasting color
        }
        .padding()
        .background(backgroundColor) // Set background color to test contrasts
        .cornerRadius(10)
        .onTapGesture {
            // Change the background color randomly on tap
            backgroundColor = Color(
                red: Double.random(in: 0...1),
                green: Double.random(in: 0...1),
                blue: Double.random(in: 0...1)
            )
        }
    }
}

#Preview {
    ContentView()
}
