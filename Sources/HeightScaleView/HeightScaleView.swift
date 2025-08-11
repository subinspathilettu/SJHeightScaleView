//
//  HeightScaleView.swift
//  HeightScaleView
//
//  Created by subinsjose on 28/07/25.
//
//  OVERVIEW
//  ========
//  HeightScaleView is a custom UI component that provides an interactive 
//  height selection interface similar to a physical measuring scale.
//
//  KEY FEATURES
//  ===========
//  - Interactive scrolling height selection from 120cm to 220cm (customizable)
//  - Visual scale with markings for each centimeter
//  - Prominent markings for each 10cm increment
//  - Segmented control to toggle between metric (cm) and imperial (ft/in) units
//  - Haptic feedback when scrolling between values
//  - Formatted display of the current height value
//
//  USAGE
//  =====
//  1. Create an instance of HeightScaleView
//     let heightScale = HeightScaleView(minimumValueInCM: 120, maximumValueInCM: 220)
//  2. Add it to your view hierarchy
//     view.addSubview(heightScale)
//  3. Set constraints to define its position and size
//     heightScale.edgesToSuperview() // Using TinyConstraints
//  4. Access the current height value through the currentValue property
//     let selectedHeight = heightScale.currentValue
//
import UIKit
import TinyConstraints

/// `HeightScaleView` is a custom UIView component that displays an interactive height scale.
///
/// The view shows a scrollable ruler-like interface that allows users to select a height value
/// between a minimum and maximum range (defaults to 120-220cm). The scale includes visual indicators 
/// for different height values and provides haptic feedback when scrolling between values.
///
/// Features:
/// - Customizable minimum and maximum height values
/// - Visual scale with major and minor tick marks
/// - Current value display with formatting
/// - Haptic feedback when scrolling between values
/// - Scrollable interface for intuitive height selection
/// - Segmented control to toggle between centimeters and feet/inches
///
/// Usage:
/// ```swift
/// // Create a height scale with default range (120-220cm)
/// let heightScale = HeightScaleView()
/// 
/// // Or with a custom range
/// let customHeightScale = HeightScaleView(minimumValueInCM: 100, maximumValueInCM: 200)
/// 
/// // Add to view hierarchy
/// view.addSubview(heightScale)
/// 
/// // Set constraints
/// heightScale.edgesToSuperview()
/// 
/// // Access the current value
/// let selectedHeight = heightScale.currentValue
/// ```
class HeightScaleView: UIView {
    /// The label that displays the currently selected height value with formatted text and units
    private let currentValueLabel = UILabel()

    /// The minimum height value (in cm) that can be selected on the scale (default: 120)
    private var _minimumValue: Int = 120

    /// The maximum height value (in cm) that can be selected on the scale (default: 220)
    private var _maximumValue: Int = 220

    /// The number of pixels representing 1 centimeter on the scale
    /// This determines the visual density of the scale markings
    private let _pixelsPerCM: Double = 10.0
    
    /// The scroll view that enables interactive scrolling through the height scale
    private var _scrollView = UIScrollView()

    /// The content view within the scroll view that contains all the scale markings
    private var _contentView = UIView()

    /// Haptic feedback generator that provides tactile feedback when changing values
    /// Uses medium impact style for a balanced feedback experience
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    /// The current selected height value on the scale (in centimeters)
    /// This value is updated as the user scrolls through the scale
    private var currentValue: Int = 0
    
    /// The unit of measurement displayed after the height value ("cm" or empty for imperial)
    private var unit = "cm"
    
    /// Flag indicating whether the scale is in metric (cm) or imperial (ft/in) mode
    /// - true: Display in centimeters
    /// - false: Display in feet and inches
    private var isMetric = true
    
    /// UI segmented control for toggling between metric and imperial units
    /// Provides two segments: "cm" for metric and "ft" for imperial
    private let unitSegmentControl = UISegmentedControl(items: ["cm", "ft"])

    /// Collection of scale value labels that need to be updated when unit changes
    /// These labels are created for each major tick mark (multiples of 10)
    private var _scaleLabels: [ScaleValueLabel] = []

    /// Initializes a new instance of HeightScaleView
    ///
    /// This initializer sets up the height scale with default configuration:
    /// - Height range from 120cm to 220cm
    /// - Medium haptic feedback
    /// - Centimeter units
    ///
    /// - Note: Use this initializer when creating the view programmatically
    init(minimumValueInCM: Int = 120, maximumValueInCM: Int = 220) {
        super.init(frame: .zero)

        _minimumValue = minimumValueInCM
        _maximumValue = maximumValueInCM
        currentValue = _minimumValue // Start at minimum value
        setUpView()
        setupUnitSwitch()

        // Initialize the feedback generator
        // It's good practice to prepare it before using it for low-latency feedback.
        feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator?.prepare()
    }

    /// Overrides the default layoutSubviews method to adjust the content view's height
    /// when the view's layout changes
    ///
    /// This ensures the content view has the correct height to display all height values
    /// while maintaining proper scrolling behavior by adding the scrollView's height to the
    /// content height so the first and last values can be scrolled to the center.
    override func layoutSubviews() {
        super.layoutSubviews()

        // Calculate the content height (pixels per cm)
        let contentHeight = _pixelsPerCM * Double(_maximumValue - _minimumValue)
        _contentView.height(CGFloat(contentHeight + _scrollView.bounds.height))
    }

    /// Required initializer for Interface Builder/Storyboard integration
    ///
    /// - Note: This implementation forces a crash as this view is designed to be created programmatically
    /// - Parameter coder: The NSCoder to decode the view from
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets up the height scale view with all its subviews and constraints
    ///
    /// This method configures:
    /// - The scroll view for interaction with proper settings (no indicators, clear background)
    /// - Scale markings (tick marks) for each cm value with appropriate styling
    /// - ScaleValueLabel instances for the major tick marks (multiples of 10)
    /// - The blue indicator line showing the current selection point
    /// - The current value label with initial value formatting
    ///
    /// The scale is visually constructed to represent the height range from _minimumValue to _maximumValue
    /// with proper spacing determined by _pixelsPerCM to ensure consistent visual density.
    private func setUpView() {
        _scrollView.showsVerticalScrollIndicator = false
        _scrollView.showsHorizontalScrollIndicator = false
        _scrollView.backgroundColor = .clear
        _scrollView.delegate = self
        _scrollView.contentInsetAdjustmentBehavior = .never // Prevent automatic content insets
        addSubview(_scrollView)
        _scrollView.edgesToSuperview()

        _scrollView.addSubview(_contentView)
        _contentView.edgesToSuperview()
        _contentView.width(to: self)

        // Set initial content offset to zero
        _scrollView.contentOffset = CGPoint.zero

        var index = 0
        // Create scale lines and labels
        for value in _minimumValue..._maximumValue {
            let isMultipleOf10 = value % 10 == 0
            let lineLength: CGFloat = isMultipleOf10 ? 40 : 10
            let yPosition = (Double(index) * _pixelsPerCM)

            // Create the scale line
            let lineView = UIView()
            lineView.backgroundColor = isMultipleOf10 ? .black : .gray
            _contentView.addSubview(lineView)
            lineView.width(lineLength)
            lineView.height(isMultipleOf10 ? 2 : 1)
            lineView.trailingToSuperview(offset: 16) // Leave space for labels
            lineView.centerY(to: _scrollView, offset: yPosition)

            // Only add labels for multiples of 5
            if isMultipleOf10 {
                let label = ScaleValueLabel()
                label.valueInCM = value
                label.text = "\(value) cm"
                label.textAlignment = .left
                label.font = .systemFont(ofSize: 14,
                                         weight: .medium)
                _contentView.addSubview(label)
                label.centerY(to: lineView)
                let offset = -1 * (lineLength + 8) // spacing
                label.trailing(to: lineView, offset: offset)
                _scaleLabels.append(label)
            }
            index += 1
        }

        // Add the current value indicator and label
        let indicatorView = UIView()
        indicatorView.backgroundColor = .systemBlue
        addSubview(indicatorView)
        indicatorView.height(2)
        // Use leading, trailing and centerY instead of center(in:)
        indicatorView.leadingToSuperview(offset: 64)
        indicatorView.trailingToSuperview(offset: 16)
        indicatorView.centerY(to: self) // Ensure vertical centering is maintained

        // Position the current value label above the indicator
        self.setValue(
            height: "\(currentValue)",
            unit: unit
        )
        addSubview(currentValueLabel)
        currentValueLabel.centerX(to: self)
        currentValueLabel.bottom(to: indicatorView, offset: -10)
    }
}

extension HeightScaleView: UIScrollViewDelegate {
    /// Handles scroll events to update the displayed height value
    ///
    /// This method:
    /// - Calculates the height value from the scroll position
    /// - Ensures the value stays within the minimum and maximum range
    /// - Updates the current value label with formatted text
    /// - Triggers haptic feedback when the value changes
    ///
    /// - Parameter scrollView: The scroll view that was scrolled
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Ensure we're only working with valid offsets
        let yOffset = max(0, scrollView.contentOffset.y)
        var value = Int(yOffset / CGFloat(_pixelsPerCM)) + _minimumValue

        // Ensure value is within bounds
        if value < _minimumValue {
            value = _minimumValue
        } else if value > _maximumValue {
            value = _maximumValue
        }

        // Update the current value label and trigger haptic feedback if value changes
        if value != currentValue {
            currentValue = value
            
            updateDisplayForCurrentValue()
            feedbackGenerator?.impactOccurred()
        }
    }

    /// Sets the value of the current height and its unit on the label with styled fonts.
    /// - Parameters:
    ///   - height: The height value to display as a string, styled with a large bold font.
    ///   - unit: The unit of measurement to display, styled with a smaller regular font.
    private func setValue(height: String,
                          unit: String) {
        let bigFont = UIFont.systemFont(ofSize: 36, weight: .bold)
        let smallFont = UIFont.systemFont(ofSize: 16, weight: .regular)

        // Create attributed string
        let attributedText = NSMutableAttributedString(
            string: height,
            attributes: [.font: bigFont, .foregroundColor: UIColor.black]
        )

        attributedText.append(NSAttributedString(
            string: " \(unit)",
            attributes: [.font: smallFont, .foregroundColor: UIColor.black]
        ))
        currentValueLabel.attributedText = attributedText
    }
    
    /// Sets up the unit segmented control for switching between metric and imperial units
    ///
    /// This method:
    /// - Adds the segmented control to the view hierarchy with proper positioning
    /// - Configures the size, corner radius, and positioning relative to other elements
    /// - Sets the initial selected segment based on the isMetric flag
    /// - Applies visual styling for both normal and selected states
    /// - Registers the value change event handler for unit conversion
    private func setupUnitSwitch() {
        // Add segmented control for unit selection
        addSubview(unitSegmentControl)
        unitSegmentControl.width(120)
        unitSegmentControl.height(50)
        unitSegmentControl.layer.cornerRadius = 30
        unitSegmentControl.centerX(to: currentValueLabel)
        unitSegmentControl.bottomToTop(of: currentValueLabel, offset: -20)

        // Set initial selection and styling
        unitSegmentControl.selectedSegmentIndex = isMetric ? 0 : 1
        unitSegmentControl.selectedSegmentTintColor = .systemBlue
        
        // Set text attributes for both normal and selected states
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        unitSegmentControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        unitSegmentControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        // Add target for value change event
        unitSegmentControl.addTarget(self,
                                    action: #selector(unitSegmentValueChanged),
                                    for: .valueChanged)
    }
    
    /// Handles the unit segment control value change event
    ///
    /// This method is called when the user toggles between metric and imperial units.
    /// It performs the following actions:
    /// 1. Updates the isMetric flag based on the selected segment
    /// 2. Updates the current value display with the appropriate unit
    /// 3. Updates all scale labels to display values in the selected unit
    ///
    /// - Note: Selected index 0 corresponds to metric (cm) and index 1 to imperial (ft/in)
    @objc private func unitSegmentValueChanged() {
        isMetric = unitSegmentControl.selectedSegmentIndex == 0
        updateDisplayForCurrentValue()
        _scaleLabels.forEach { $0.isMetric = isMetric }
    }
    
    /// Updates the display to show the current height in the selected unit
    ///
    /// This method is called whenever:
    /// 1. The current height value changes (through scrolling)
    /// 2. The unit selection changes (metric/imperial toggle)
    ///
    /// For metric display, it shows the value directly in centimeters.
    /// For imperial display, it converts the centimeter value to feet and inches
    /// using the appropriate conversion formula and formats it as "X'Y"".
    private func updateDisplayForCurrentValue() {
        if isMetric {
            unit = "cm"
            setValue(height: "\(currentValue)", unit: unit)
        } else {
            // Convert cm to feet and inches
            let (feet, inches) = currentValue.convertCMToFeetAndInches()
            self.setValue(height: "\(feet)'\(inches)\"", unit: "")
        }
    }
}

/// Extension to Int for height conversion utilities
extension Int {
    /// Converts a height value in centimeters to feet and inches
    ///
    /// This utility method provides a convenient way to convert height measurements
    /// from the metric system (centimeters) to the imperial system (feet and inches).
    ///
    /// The conversion uses the standard formula:
    /// 1. 1 centimeter = 0.393701 inches
    /// 2. 12 inches = 1 foot
    ///
    /// - Returns: A tuple containing the height in (feet, inches)
    ///
    /// Example:
    /// ```
    /// let height = 183 // 183 cm
    /// let (feet, inches) = height.convertCMToFeetAndInches()
    /// // feet = 6, inches = 0
    /// ```
    func convertCMToFeetAndInches() -> (Int, Int) {
        let totalInches = Double(self) * 0.393701
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return (feet, inches)
    }
}
