//
//  ContentView.swift
//  SJHeightScaleViewExample
//
//  Created by subinsjose on 28/07/25.
//

import SwiftUI
import SJHeightScaleView

@available(iOS 17.0, *)
struct ContentView: View {

    @State private var selectedHeight: Double = 175.0
    @State private var selectedUnit: HeightUnit = .centimeters
    @State private var showingSecondExample = false

    var body: some View {
        VStack {
            HeightScaleView(
                selectedHeight: $selectedHeight,
                minHeight: unitRange.min,
                maxHeight: unitRange.max,
                unit: selectedUnit,
                tickInterval: unitRange.interval
            )
        }
        .padding()
    }

    private var unitRange: (min: Double, max: Double, interval: Double) {
        switch selectedUnit {
        case .centimeters:
            return (140, 220, 1)
        case .inches:
            return (48, 84, 1)
        case .feet:
            return (4.0, 7.5, 0.1)
        }
    }
}

#Preview {
    ContentView()
}
