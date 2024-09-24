import UIKit

public protocol ProgrammaticallyDesignable: AnyObject {
    /// Setup view parameters (e.g. set colors, fonts, etc)
    func setupView()
    /// Set up subviews hierarchy
    func addSubviews()
    /// Add constraints
    func makeConstraints()
}

public extension ProgrammaticallyDesignable where Self: UIView {
    func setupView() {
        // Empty body to make method optional
    }

    func addSubviews() {
        // Empty body to make method optional
    }

    func makeConstraints() {
        // Empty body to make method optional
    }
}
