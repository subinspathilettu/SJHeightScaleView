import SwiftUI

public struct HeightScaleView: View {
    @Binding public var selectedHeight: Double

    public let minHeight: Double
    public let maxHeight: Double
    public let unit: HeightUnit
    public let tickInterval: Double

    private let scaleHeight: CGFloat = 300
    private let tickWidth: CGFloat = 20
    private let majorTickWidth: CGFloat = 30

    public init(
        selectedHeight: Binding<Double>,
        minHeight: Double = 100,
        maxHeight: Double = 250,
        unit: HeightUnit = .centimeters,
        tickInterval: Double = 1
    ) {
        self._selectedHeight = selectedHeight
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.unit = unit
        self.tickInterval = tickInterval
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Scale background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 60)

                // Scale ticks
                VStack(spacing: 0) {
                    ForEach(tickMarks, id: \.self) { tick in
                        HStack {
                            Spacer()

                            Rectangle()
                                .fill(Color.primary)
                                .frame(
                                    width: tick.rounded(.toNearestOrEven) == tick ? majorTickWidth : tickWidth,
                                    height: 1
                                )

                            if tick.truncatingRemainder(dividingBy: 10) == 0 {
                                Text("\(Int(tick))")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .padding(.leading, 4)
                            }

                            Spacer()
                        }
                        .frame(height: tickSpacing)
                    }
                }

                // Selection indicator
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 3)
                        .cornerRadius(1.5)
                    Spacer()
                }
                .offset(y: indicatorOffset)

                // Selected value display
                VStack {
                    HStack {
                        Text("\(selectedHeight, specifier: "%.1f") \(unit.symbol)")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                            )
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .frame(width: 120, height: scaleHeight)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newHeight = heightFromOffset(value.location.y)
                    selectedHeight = max(minHeight, min(maxHeight, newHeight))
                }
        )
    }

    private var tickMarks: [Double] {
        stride(from: minHeight, through: maxHeight, by: tickInterval).map { $0 }
    }

    private var tickSpacing: CGFloat {
        scaleHeight / CGFloat(tickMarks.count - 1)
    }

    private var indicatorOffset: CGFloat {
        let progress = (selectedHeight - minHeight) / (maxHeight - minHeight)
        return CGFloat(progress) * scaleHeight - scaleHeight / 2
    }

    private func heightFromOffset(_ offset: CGFloat) -> Double {
        let progress = offset / scaleHeight
        return minHeight + progress * (maxHeight - minHeight)
    }
}

public enum HeightUnit: String, CaseIterable {
    case centimeters = "cm"
    case inches = "in"
    case feet = "ft"

    public var symbol: String {
        return self.rawValue
    }
}

// MARK: - Preview
struct HeightScaleView_Previews: PreviewProvider {
    @State static var height: Double = 175

    static var previews: some View {
        HeightScaleView(
            selectedHeight: $height,
            minHeight: 150,
            maxHeight: 200,
            unit: .centimeters
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
