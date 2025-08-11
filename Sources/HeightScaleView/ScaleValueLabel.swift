//
//  ScaleValueLabel.swift
//  HeightScaleView
//
//  Created by subinsjose on 29/07/25.
//

import UIKit

/// `ScaleValueLabel` is a specialized UILabel subclass that displays height values on the scale
/// with automatic unit formatting based on the selected measurement system.
///
/// This class is used for the labels that appear next to the major tick marks on the height scale.
/// It automatically formats the display value when the measurement system changes between
/// metric (cm) and imperial (feet/inches).
///
/// Features:
/// - Automatic text updating when the height value changes
/// - Automatic unit conversion between metric and imperial systems
/// - Proper formatting for both centimeters and feet/inches
class ScaleValueLabel: UILabel {

    /// The height value in centimeters that this label represents
    ///
    /// When this value is set, the label's text is automatically updated to display
    /// the value with the appropriate unit based on the current measurement system.
    var valueInCM: Int = 0 {
        didSet {
            text = "\(valueInCM) cm"
        }
    }

    /// Flag indicating whether the label should display the value in metric (cm) or imperial (ft/in) units
    ///
    /// When this value changes, the label's text is automatically updated to display
    /// the current height value in the appropriate unit format:
    /// - true: Display in centimeters (e.g., "180 cm")
    /// - false: Display in feet and inches (e.g., "5'11"")
    var isMetric = true {
        didSet {
            if isMetric {
                text = "\(valueInCM) cm"
            } else {
                let (feet, inches) = valueInCM.convertCMToFeetAndInches()
                text = "\(feet)'\(inches)\""
            }
        }
    }
}
